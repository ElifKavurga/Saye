package com.elifkavurga.backend.report;

import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
import com.elifkavurga.backend.report.entity.ReportStatus;
import com.elifkavurga.backend.report.repository.ReportRepository;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.time.Instant;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
class ReportControllerIntegrationTest {

    private MockMvc mvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private ReportRepository reportRepository;

    @Autowired
    private UserRepository userRepository;

    private Long ownerUserId;
    private Long anotherUserId;
    private Long newReportUserId;
    private Long outsiderUserId;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        reportRepository.deleteAll();

        ownerUserId = createUser("report-owner");
        anotherUserId = createUser("report-another");
        newReportUserId = createUser("report-new");
        outsiderUserId = createUser("report-outsider");

        Report mine = new Report();
        mine.setUser(userRepository.findById(ownerUserId).orElseThrow());
        mine.setCategory(ReportCategory.SECURITY);
        mine.setDescription("Benim kaydim");
        mine.setLatitude(41.0);
        mine.setLongitude(29.0);
        mine.setCreatedAt(Instant.parse("2026-03-01T10:00:00Z"));
        reportRepository.save(mine);

        Report another = new Report();
        another.setUser(userRepository.findById(anotherUserId).orElseThrow());
        another.setCategory(ReportCategory.TRAFFIC);
        another.setDescription("Baska kullanici");
        another.setLatitude(41.1);
        another.setLongitude(29.1);
        another.setCreatedAt(Instant.parse("2026-03-01T11:00:00Z"));
        reportRepository.save(another);
    }

    @Test
    void createReportWorks() throws Exception {
        mvc.perform(post("/api/reports")
                        .contentType(MediaType.APPLICATION_JSON)
                .content("""
                                {
                                  "userId": %d,
                                  "category": "SECURITY",
                                  "description": "Yeni bildirim",
                                  "latitude": 41.0082,
                                  "longitude": 28.9784
                                }
                                """.formatted(newReportUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.userId").value(newReportUserId))
                .andExpect(jsonPath("$.data.category").value("SECURITY"))
                .andExpect(jsonPath("$.data.description").value("Yeni bildirim"));
    }

    @Test
    void listMineReturnsOnlyUsersReports() throws Exception {
        mvc.perform(get("/api/reports/mine").param("userId", String.valueOf(ownerUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].userId").value(ownerUserId))
                .andExpect(jsonPath("$.data[0].description").value("Benim kaydim"));
    }

    @Test
    void ownerCanResolveOwnReport() throws Exception {
        Long reportId = reportRepository.findAllByUser_IdOrderByCreatedAtDesc(ownerUserId).get(0).getId();

        mvc.perform(patch("/api/reports/{id}/status", reportId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "status": "RESOLVED",
                                  "requestedByUserId": %d
                                }
                                """.formatted(ownerUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("RESOLVED"));
    }

    @Test
    void anotherUserCannotUpdateStatus() throws Exception {
        Long reportId = reportRepository.findAllByUser_IdOrderByCreatedAtDesc(ownerUserId).get(0).getId();

        mvc.perform(patch("/api/reports/{id}/status", reportId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "status": "RESOLVED",
                                  "requestedByUserId": %d
                                }
                                """.formatted(outsiderUserId)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Bu raporun durumunu guncelleme yetkin yok"));
    }

    @Test
    void adminCanUpdateAnyReport() throws Exception {
        Long reportId = reportRepository.findAllByUser_IdOrderByCreatedAtDesc(anotherUserId).get(0).getId();

        mvc.perform(patch("/api/reports/{id}/status", reportId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "status": "REJECTED",
                                  "admin": true
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("REJECTED"));
    }

    private Long createUser(String label) {
        User user = new User();
        String uniqueUsername = label + "-" + System.nanoTime();
        user.setEmail(label + "+" + System.nanoTime() + "@test.local");
        user.setPassword("test");
        user.setUsername(uniqueUsername);
        return userRepository.save(user).getId();
    }
}
