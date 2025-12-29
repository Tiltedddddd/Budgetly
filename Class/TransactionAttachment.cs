using System;

namespace Budgetly.Class
{
    public class TransactionAttachment
    {
        public int AttachmentID { get; set; }
        public int TransactionID { get; set; }
        public string FilePath { get; set; }
        public string FileType { get; set; }
        public DateTime UploadedOn { get; set; }
    }
}
