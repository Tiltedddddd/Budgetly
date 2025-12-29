using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Budgetly.Class
{
    using System;

    namespace Budgetly.Class
    {
        public class User
        {
            public int UserID { get; set; }
            public string Email { get; set; }
            public string PasswordHash { get; set; }
            public string FullName { get; set; }
            public DateTime CreatedOn { get; set; }
            public int ResetDay { get; set; }
            public bool IsActive { get; set; }
        }
    }

}