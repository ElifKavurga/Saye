package com.elifkavurga.backend.report;

import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
import com.elifkavurga.backend.report.entity.ReportStatus;
import com.elifkavurga.backend.report.repository.ReportRepository;
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

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        reportRepository.deleteAll();

        Report mine = new Report();
        mine.setUserId(10L);
        mine.setCategory(ReportCategory.SUC);
        mine.setDescription("Benim kaydim");
        mine.setLatitude(41.0);
        mine.setLongitude(29.0);
        mine.setCreatedAt(Instant.parse("2026-03-01T10:00:00Z"));
        reportRepository.save(mine);

        Report another = new Report();
        another.setUserId(20L);
        another.setCategory(ReportCategory.TRAFIK);
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
                                  "userId": 30,
                                  "category": "SUC",
                                  "description": "Yeni bildirim",
                                  "latitude": 41.0082,
                                  "longitude": 28.9784
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.userId").value(30))
                .andExpect(jsonPath("$.data.category").value("SUC"))
                .andExpect(jsonPath("$.data.description").value("Yeni bildirim"));
    }

    @Test
    void listMineReturnsOnlyUsersReports() throws Exception {
        mvc.perform(get("/api/reports/mine").param("userId", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].userId").value(10))
                .andExpect(jsonPath("$.data[0].description").value("Benim kaydim"));
    }

    @Test
    void ownerCanResolveOwnReport() throws Exception {
        Long reportId = reportRepository.findAllByUserIdOrderByCreatedAtDesc(10L).get(0).getId();

        mvc.perform(patch("/api/reports/{id}/status", reportId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "status": "RESOLVED",
                                  "requestedByUserId": 10
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("RESOLVED"));
    }

    @Test
    void anotherUserCannotUpdateStatus() throws Exception {
        Long reportId = reportRepository.findAllByUserIdOrderByCreatedAtDesc(10L).get(0).getId();

        mvc.perform(patch("/api/reports/{id}/status", reportId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "status": "RESOLVED",
                                  "requestedByUserId": 99
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Bu raporun durumunu guncelleme yetkin yok"));
    }

    @Test
    void adminCanUpdateAnyReport() throws Exception {
        Long reportId = reportRepository.findAllByUserIdOrderByCreatedAtDesc(20L).get(0).getId();

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
}
