using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Http;
using Budgetly.Models.DTOs;

namespace Budgetly.Controllers
{
    public class RegistrationController : ApiController
    {
        private string connString = ConfigurationManager.ConnectionStrings["BudgetlyDB"].ConnectionString;

        [HttpPost]
        [Route("api/auth/signup")]
        public IHttpActionResult SignUp(RegistrationRequestDto request)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    // Transaction ensures both User and Profile are created or none
                    using (SqlTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Insert into Users Table
                            string userSql = @"INSERT INTO Users (Email, PasswordHash, FullName, ResetDay, IsActive) 
                                             OUTPUT INSERTED.UserID 
                                             VALUES (@Email, @Pass, @Name, @Reset, 1)";

                            int newUserId;
                            using (SqlCommand cmd = new SqlCommand(userSql, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@Email", request.Email);
                                // Note: In production, use BCrypt or Argon2 to hash passwords
                                cmd.Parameters.AddWithValue("@Pass", request.Password);
                                cmd.Parameters.AddWithValue("@Name", request.FullName);
                                cmd.Parameters.AddWithValue("@Reset", request.ResetDay);
                                newUserId = (int)cmd.ExecuteScalar();
                            }

                            // 2. Create User Profile (1-to-1)
                            string profileSql = "INSERT INTO UserProfiles (UserID, DisplayName) VALUES (@UID, @DName)";
                            using (SqlCommand cmd = new SqlCommand(profileSql, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@UID", newUserId);
                                cmd.Parameters.AddWithValue("@DName", request.FullName.Split(' ')[0]);
                                cmd.ExecuteNonQuery();
                            }

                            trans.Commit();
                            return Ok(new { Success = true, Message = "User created successfully" });
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            return InternalServerError(ex);
                        }
                    }
                }
            }
            catch (Exception ex) { return InternalServerError(ex); }
        }

        [HttpPost]
        [Route("api/auth/login")]
        public IHttpActionResult Login(LoginRequestDto request)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT UserID, FullName, PasswordHash FROM Users WHERE Email = @Email AND IsActive = 1";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", request.Email);

                conn.Open();
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string dbHash = rdr["PasswordHash"].ToString();
                        if (request.Password == dbHash) // Compare hashed passwords in production
                        {
                            return Ok(new AuthResponseDto
                            {
                                Success = true,
                                UserID = (int)rdr["UserID"],
                                FullName = rdr["FullName"].ToString()
                            });
                        }
                    }
                }
            }
            return Unauthorized();
        }
    }
}