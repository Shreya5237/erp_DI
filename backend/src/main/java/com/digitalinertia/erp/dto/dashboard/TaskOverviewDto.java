package com.digitalinertia.erp.dto.dashboard;

public class TaskOverviewDto {
    private long total;
    private long completed;
    private long inProgress;
    private long todo;
    private long overdue;
    private long needsRework;

    public TaskOverviewDto() {}

    public TaskOverviewDto(long total, long completed, long inProgress, long todo, long overdue, long needsRework) {
        this.total = total;
        this.completed = completed;
        this.inProgress = inProgress;
        this.todo = todo;
        this.overdue = overdue;
        this.needsRework = needsRework;
    }

    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }

    public long getCompleted() { return completed; }
    public void setCompleted(long completed) { this.completed = completed; }

    public long getInProgress() { return inProgress; }
    public void setInProgress(long inProgress) { this.inProgress = inProgress; }

    public long getTodo() { return todo; }
    public void setTodo(long todo) { this.todo = todo; }

    public long getOverdue() { return overdue; }
    public void setOverdue(long overdue) { this.overdue = overdue; }

    public long getNeedsRework() { return needsRework; }
    public void setNeedsRework(long needsRework) { this.needsRework = needsRework; }
}
