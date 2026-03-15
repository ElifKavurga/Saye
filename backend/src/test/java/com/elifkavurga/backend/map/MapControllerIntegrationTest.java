package com.elifkavurga.backend.map;

import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
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
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
public class MapControllerIntegrationTest {
    private MockMvc mvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private ReportRepository repo;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        repo.deleteAll();
        // same data as MapServiceIntegrationTest
        Report r1 = new Report();
        r1.setCategory(ReportCategory.SECURITY);
        r1.setDescription("Crime close");
        r1.setLatitude(0.0);
        r1.setLongitude(0.0);
        r1.setCreatedAt(Instant.now().minusSeconds(60));
        repo.save(r1);

        Report r2 = new Report();
        r2.setCategory(ReportCategory.LIGHTING);
        r2.setDescription("Followed a bit further");
        r2.setLatitude(0.005);
        r2.setLongitude(0.0);
        r2.setCreatedAt(Instant.now().minusSeconds(3600));
        repo.save(r2);

        Report r4 = new Report();
        r4.setCategory(ReportCategory.SECURITY);
        r4.setDescription("Crime same block");
        r4.setLatitude(0.001);
        r4.setLongitude(0.0);
        r4.setCreatedAt(Instant.now().minusSeconds(180));
        repo.save(r4);

        Report r3 = new Report();
        r3.setCategory(ReportCategory.ANIMALS);
        r3.setDescription("Animal far away");
        r3.setLatitude(0.02);
        r3.setLongitude(0.0);
        r3.setCreatedAt(Instant.now().minusSeconds(3600));
        repo.save(r3);
    }

    @Test
    void reportsEndpointWorks() throws Exception {
        mvc.perform(get("/map/reports")
                .param("lat", "0")
                .param("lng", "0")
                .param("radius", "1000"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[0].description").exists())
                .andExpect(jsonPath("$[0].riskRadiusMeters").isNumber())
                .andExpect(jsonPath("$[0].riskLevel").isString())
                .andExpect(jsonPath("$[0].riskCircleId").isString());
    }

    @Test
    void riskEndpointWorks() throws Exception {
        mvc.perform(get("/risk")
                .param("lat", "0")
                .param("lng", "0"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.score").isNumber())
                .andExpect(jsonPath("$.level").isString());
    }
}
