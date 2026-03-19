package com.elifkavurga.backend.config;

import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
import com.elifkavurga.backend.report.entity.ReportStatus;
import com.elifkavurga.backend.report.repository.ReportRepository;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.entity.UserRole;
import com.elifkavurga.backend.user.repository.UserRepository;
import com.elifkavurga.backend.security.EmailHashService;
import com.elifkavurga.backend.userhealthprofile.entity.UserHealthProfile;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    private static final GeometryFactory GEOMETRY_FACTORY = new GeometryFactory(new PrecisionModel(), 4326);

    private final UserRepository userRepository;
    private final ReportRepository reportRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JdbcTemplate jdbcTemplate;
    private final EmailHashService emailHashService;

    @Override
    public void run(String... args) {
        try {
            ensureSpatialDatabaseObjects();
        } catch (Exception ex) {
            logger.warn("DataInitializer migration step skipped due to DB schema issue: {}", ex.getMessage());
        }

        List<User> seededUsers = new ArrayList<>();

        if (userRepository.count() == 0) {
            User admin = new User();
            admin.setEmail("admin@saye.local");
            admin.setEmailHash(emailHashService.hashEmail("admin@saye.local"));
            admin.setPassword(passwordEncoder.encode("Admin123!"));
            admin.setUsername("admin");
            admin.setPhone("5550000000");
            admin.setIsActive(true);
            admin.setRole(UserRole.ADMIN);
            admin.setHealthProfile(new UserHealthProfile());

            User user = new User();
            user.setEmail("user@saye.local");
            user.setEmailHash(emailHashService.hashEmail("user@saye.local"));
            user.setPassword(passwordEncoder.encode("User123!"));
            user.setUsername("test-user");
            user.setPhone("5551112233");
            user.setIsActive(true);
            user.setRole(UserRole.USER);
            user.setHealthProfile(new UserHealthProfile());

            try {
                seededUsers = userRepository.saveAll(List.of(admin, user));
            } catch (Exception ex) {
                logger.warn("Default user seed could not be created: {}", ex.getMessage());
                return;
            }
        }

        if (reportRepository.count() == 0) {
            User defaultUser;
            if (!seededUsers.isEmpty()) {
                defaultUser = seededUsers.get(1);
            } else {
                defaultUser = userRepository.findByEmailHash(emailHashService.hashEmail("user@saye.local"))
                        .or(() -> userRepository.findAll().stream().findFirst())
                        .orElse(null);
            }

            List<Report> seedReports = List.of(
                    buildReport(defaultUser, ReportCategory.LIGHTING, "Kampus girisinde aydinlatma eksikligi var", 38.3552, 38.3095),
                    buildReport(defaultUser, ReportCategory.ANIMALS, "Yurtlar bolgesinde kopek surusu goruldu", 38.3571, 38.3120),
                    buildReport(defaultUser, ReportCategory.SECURITY, "Merkezi kutuphane yakininda gece guvenlik zayif", 38.3538, 38.3079),
                    buildReport(defaultUser, ReportCategory.TRAFFIC, "Kampus ana kapida trafik sikisiyor", 38.3519, 38.3142),
                    buildReport(defaultUser, ReportCategory.INFRASTRUCTURE, "Yuruyus yolunda kaldirim hasari var", 38.3564, 38.3058)
            );
            try {
                reportRepository.saveAll(seedReports);
            } catch (Exception ex) {
                logger.warn("Default report seed could not be created: {}", ex.getMessage());
            }
        }
    }

    private Report buildReport(User user, ReportCategory category, String description, double latitude, double longitude) {
        Report report = new Report();
        report.setUser(user);
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

    private void ensureSpatialDatabaseObjects() {
        jdbcTemplate.execute("ALTER TABLE users DROP COLUMN IF EXISTS first_name CASCADE");
        jdbcTemplate.execute("ALTER TABLE users DROP COLUMN IF EXISTS last_name CASCADE");
        jdbcTemplate.execute(
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true"
        );
        jdbcTemplate.execute("UPDATE users SET is_active = true WHERE is_active IS NULL");
        jdbcTemplate.execute("ALTER TABLE users ALTER COLUMN is_active SET DEFAULT true");
        jdbcTemplate.execute("ALTER TABLE users ALTER COLUMN is_active SET NOT NULL");
        jdbcTemplate.execute(
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS role varchar(20) NOT NULL DEFAULT 'USER'"
        );
        jdbcTemplate.execute("UPDATE users SET role = 'USER' WHERE role IS NULL");
        jdbcTemplate.execute("ALTER TABLE users ALTER COLUMN role SET DEFAULT 'USER'");
        jdbcTemplate.execute("ALTER TABLE users ALTER COLUMN role SET NOT NULL");
        jdbcTemplate.execute("CREATE EXTENSION IF NOT EXISTS postgis");
        jdbcTemplate.execute("""
                CREATE INDEX IF NOT EXISTS idx_reports_location
                ON reports
                USING GIST(location)
                """);
        jdbcTemplate.update("""
                UPDATE reports
                SET category = 'LIGHTING'
                WHERE category IN ('HEALTH', 'SAGLIK', 'SAÄLIK')
                """);
        jdbcTemplate.update("""
                UPDATE reports
                SET category = 'INFRASTRUCTURE'
                WHERE category IN ('TRACKING', 'TAKIP')
                """);
        jdbcTemplate.execute("""
                ALTER TABLE user_settings
                ADD COLUMN IF NOT EXISTS bluetooth_enabled boolean NOT NULL DEFAULT true
                """);
        jdbcTemplate.execute("""
                ALTER TABLE user_settings
                ADD COLUMN IF NOT EXISTS gsm_sms_enabled boolean NOT NULL DEFAULT false
                """);
        jdbcTemplate.execute("""
                ALTER TABLE user_settings
                ADD COLUMN IF NOT EXISTS quick_unlock_access_enabled boolean NOT NULL DEFAULT false
                """);
        jdbcTemplate.execute("""
                ALTER TABLE notification_logs
                DROP CONSTRAINT IF EXISTS notification_logs_type_check
                """);
        jdbcTemplate.execute("""
                ALTER TABLE notification_logs
                ADD CONSTRAINT notification_logs_type_check
                CHECK (type IN ('CALL', 'SMS', 'PUSH'))
                """);
    }
}
