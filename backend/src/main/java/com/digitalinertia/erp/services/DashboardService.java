package com.digitalinertia.erp.services;

import com.digitalinertia.erp.dto.dashboard.DashboardAlertDto;
import com.digitalinertia.erp.dto.dashboard.DashboardKpiDto;
import com.digitalinertia.erp.dto.dashboard.TaskOverviewDto;
import com.digitalinertia.erp.entities.AlertThresholdSettingsEntity;
import com.digitalinertia.erp.entities.EmployeeEntity;
import com.digitalinertia.erp.entities.InternEntity;
import com.digitalinertia.erp.entities.ProjectEntity;
import com.digitalinertia.erp.entities.enums.AlertSeverity;
import com.digitalinertia.erp.entities.enums.TaskStatus;
import com.digitalinertia.erp.repositories.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class DashboardService {

    private final EmployeeRepository employeeRepository;
    private final InternRepository internRepository;
    private final TaskRepository taskRepository;
    private final ProjectRepository projectRepository;
    private final LeadRepository leadRepository;
    private final AlertThresholdSettingsRepository settingsRepository;

    public DashboardService(
            EmployeeRepository employeeRepository,
            InternRepository internRepository,
            TaskRepository taskRepository,
            ProjectRepository projectRepository,
            LeadRepository leadRepository,
            AlertThresholdSettingsRepository settingsRepository) {
        this.employeeRepository = employeeRepository;
        this.internRepository = internRepository;
        this.taskRepository = taskRepository;
        this.projectRepository = projectRepository;
        this.leadRepository = leadRepository;
        this.settingsRepository = settingsRepository;
    }

    public DashboardKpiDto getKpis() {
        LocalDate today = LocalDate.now();
        AlertThresholdSettingsEntity settings = getSettings();

        long totalEmployees = employeeRepository.countByActiveTrue();
        long activeInterns = internRepository.countByActiveTrue();
        long pendingTasks = taskRepository.countPendingTasks();
        long activeProjects = projectRepository.countActiveProjects();
        long activeLeads = leadRepository.countActiveLeads();
        long overdueTasks = taskRepository.countOverdueTasks(today);

        long delayedProjects = projectRepository.findAll().stream()
                .filter(p -> p.getBehindSchedulePercent() != null &&
                        p.getBehindSchedulePercent() >= settings.getProjectBehindSchedulePercent())
                .count();

        return new DashboardKpiDto(
                totalEmployees,
                activeInterns,
                pendingTasks,
                activeProjects,
                activeLeads,
                overdueTasks,
                delayedProjects
        );
    }

    public List<DashboardAlertDto> getActiveAlerts() {
        List<DashboardAlertDto> alerts = new ArrayList<>();
        LocalDate today = LocalDate.now();
        AlertThresholdSettingsEntity settings = getSettings();

        // 1. Overdue Tasks Alert
        long overdueCount = taskRepository.countOverdueTasks(today);
        if (overdueCount > 0) {
            alerts.add(new DashboardAlertDto(
                    "ALERT-TSK",
                    "Tasks",
                    overdueCount + " tasks are overdue",
                    "Overdue deliverables breaching corporate SLA deadlines.",
                    AlertSeverity.critical,
                    (int) overdueCount
            ));
        }

        // 2. Interns Missed Updates Alert
        List<InternEntity> missedUpdateInterns = internRepository
                .findByMissedUpdatesDaysGreaterThanEqual(settings.getInternMissedUpdateDays());
        if (!missedUpdateInterns.isEmpty()) {
            alerts.add(new DashboardAlertDto(
                    "ALERT-INT",
                    "Interns",
                    missedUpdateInterns.size() + " interns missed daily standup updates",
                    "Interns haven't submitted daily standup notes for 2+ consecutive business days.",
                    AlertSeverity.warning,
                    missedUpdateInterns.size()
            ));
        }

        // 3. Projects Delayed Alert
        List<ProjectEntity> delayedProjects = projectRepository.findAll().stream()
                .filter(p -> p.getBehindSchedulePercent() != null &&
                        p.getBehindSchedulePercent() >= settings.getProjectBehindSchedulePercent())
                .toList();
        if (!delayedProjects.isEmpty()) {
            alerts.add(new DashboardAlertDto(
                    "ALERT-PRJ",
                    "Projects",
                    delayedProjects.size() + " projects running > " + settings.getProjectBehindSchedulePercent() + "% behind schedule",
                    "Milestone progress lagging planned progress baseline.",
                    AlertSeverity.critical,
                    delayedProjects.size()
            ));
        }

        // 4. Employee Workload Overload Alert
        List<EmployeeEntity> overloadedEmployees = employeeRepository.findByActiveTrue().stream()
                .filter(e -> e.getCurrentActiveTasks() >= settings.getEmployeeCapacityMaxTasks())
                .toList();
        if (!overloadedEmployees.isEmpty()) {
            alerts.add(new DashboardAlertDto(
                    "ALERT-EMP",
                    "Employees",
                    overloadedEmployees.size() + " key engineers at peak capacity threshold",
                    "Assignees at or exceeding " + settings.getEmployeeCapacityMaxTasks() + " active tasks concurrently.",
                    AlertSeverity.warning,
                    overloadedEmployees.size()
            ));
        }

        return alerts;
    }

    public TaskOverviewDto getTaskOverview() {
        LocalDate today = LocalDate.now();
        long total = taskRepository.count();
        long completed = taskRepository.countByStatus(TaskStatus.completed);
        long inProgress = taskRepository.countByStatus(TaskStatus.in_progress);
        long todo = taskRepository.countByStatus(TaskStatus.todo);
        long needsRework = taskRepository.countByStatus(TaskStatus.needs_rework);
        long overdue = taskRepository.countOverdueTasks(today);

        return new TaskOverviewDto(total, completed, inProgress, todo, overdue, needsRework);
    }

    private AlertThresholdSettingsEntity getSettings() {
        return settingsRepository.findById(1).orElseGet(AlertThresholdSettingsEntity::new);
    }
}
