namespace Sdnd_api.Models;

public class DocTask
{
     public int Id { get; set; }
     public string Description { get; set; }
     public TaskState State { get; set; }
     public Guid SharedDocumentId { get; set; }
     public Guid AssignedUserId { get; set; }
}

public enum TaskState
{
     Pending,
     InProgress,
     Completed
}

