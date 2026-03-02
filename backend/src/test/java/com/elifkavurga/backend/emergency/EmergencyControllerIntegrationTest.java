package com.elifkavurga.backend.emergency;

import com.elifkavurga.backend.emergency.repository.EmergencyEventRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
class EmergencyControllerIntegrationTest {

    private MockMvc mvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private EmergencyEventRepository repository;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        repository.deleteAll();
    }

    @Test
    void startAndStatusFlowWorks() throws Exception {
        mvc.perform(post("/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": 42,
                                  "latitude": 41.0082,
                                  "longitude": 28.9784,
                                  "sharedTo": ["anne", "kardes"]
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(true))
                .andExpect(jsonPath("$.data.userId").value(42))
                .andExpect(jsonPath("$.data.sharedTo.length()").value(2));

        mvc.perform(get("/emergency/status").param("userId", "42"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(true))
                .andExpect(jsonPath("$.data.latitude").value(41.0082))
                .andExpect(jsonPath("$.data.longitude").value(28.9784));
    }

    @Test
    void stopMarksEventInactive() throws Exception {
        mvc.perform(post("/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": 42,
                                  "latitude": 41.0082,
                                  "longitude": 28.9784
                                }
                                """))
                .andExpect(status().isOk());

        mvc.perform(post("/emergency/stop")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": 42
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(false))
                .andExpect(jsonPath("$.data.endedAt").exists());

        mvc.perform(get("/emergency/status").param("userId", "42"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(false));
    }

    @Test
    void cannotStartSecondActiveEmergency() throws Exception {
        mvc.perform(post("/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": 42,
                                  "latitude": 41.0082,
                                  "longitude": 28.9784
                                }
                                """))
                .andExpect(status().isOk());

        mvc.perform(post("/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": 42,
                                  "latitude": 41.1,
                                  "longitude": 29.1
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Kullanicinin zaten aktif bir acil durumu var"));
    }
}
