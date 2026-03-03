package com.elifkavurga.backend.config;

import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
import com.elifkavurga.backend.report.entity.ReportStatus;
import com.elifkavurga.backend.report.repository.ReportRepository;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.entity.UserRole;
import com.elifkavurga.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private static final GeometryFactory GEOMETRY_FACTORY = new GeometryFactory(new PrecisionModel(), 4326);

    private final UserRepository userRepository;
    private final ReportRepository reportRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        List<User> seededUsers = new ArrayList<>();

        if (userRepository.count() == 0) {
            User admin = new User();
            admin.setEmail("admin@saye.local");
            admin.setPassword(passwordEncoder.encode("Admin123!"));
            admin.setPasswordHash(admin.getPassword());
            admin.setFirstName("Saye");
            admin.setLastName("Admin");
            admin.setUsername("admin");
            admin.setRole(UserRole.ADMIN);
            admin.setIsActive(true);

            User user = new User();
            user.setEmail("user@saye.local");
            user.setPassword(passwordEncoder.encode("User123!"));
            user.setPasswordHash(user.getPassword());
            user.setFirstName("Test");
            user.setLastName("User");
            user.setUsername("test-user");
            user.setRole(UserRole.USER);
            user.setIsActive(true);

            seededUsers = userRepository.saveAll(List.of(admin, user));
        }

        if (reportRepository.count() == 0) {
            Long defaultUserId;
            if (!seededUsers.isEmpty()) {
                defaultUserId = seededUsers.get(1).getId();
            } else {
                defaultUserId = userRepository.findByEmail("user@saye.local")
                        .or(() -> userRepository.findAll().stream().findFirst())
                        .map(User::getId)
                        .orElse(null);
            }

            List<Report> seedReports = List.of(
                    buildReport(defaultUserId, ReportCategory.LIGHTING, "Kampus girisinde aydinlatma eksikligi var", 38.3552, 38.3095),
                    buildReport(defaultUserId, ReportCategory.ANIMALS, "Yurtlar bolgesinde kopek surusu goruldu", 38.3571, 38.3120),
                    buildReport(defaultUserId, ReportCategory.SECURITY, "Merkezi kutuphane yakininda gece guvenlik zayif", 38.3538, 38.3079),
                    buildReport(defaultUserId, ReportCategory.TRAFFIC, "Kampus ana kapida trafik sikisiyor", 38.3519, 38.3142),
                    buildReport(defaultUserId, ReportCategory.INFRASTRUCTURE, "Yuruyus yolunda kaldirim hasari var", 38.3564, 38.3058)
            );

            reportRepository.saveAll(seedReports);
        }
    }

    private Report buildReport(Long userId, ReportCategory category, String description, double latitude, double longitude) {
        Report report = new Report();
        report.setUserId(userId);
        report.setCategory(category);
        report.setDescription(description);
        report.setStatus(ReportStatus.PENDING);
        report.setConfidenceScore(0.6);
        report.setLocation(createPoint(longitude, latitude));
        return report;
    }

    private Point createPoint(double longitude, double latitude) {
        Point point = GEOMETRY_FACTORY.createPoint(new Coordinate(longitude, latitude));
        point.setSRID(4326);
        return point;
    }
}
