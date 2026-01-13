using System;

namespace Budgetly.Models.DTOs
{
    // DTO for capturing Sign Up information
    public class RegistrationRequestDto
    {
        public string Email { get; set; }
        public string Password { get; set; }
        public string FullName { get; set; }
        public int ResetDay { get; set; } = 1; // Default to 1st of month
    }

    // DTO for Login credentials
    public class LoginRequestDto
    {
        public string Email { get; set; }
        public string Password { get; set; }
    }

    // DTO for returning User Session info after successful login
    public class AuthResponseDto
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public int UserID { get; set; }
        public string FullName { get; set; }
    }
}