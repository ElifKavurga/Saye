package com.elifkavurga.backend.emergency;

import com.elifkavurga.backend.emergency.repository.EmergencyEventRepository;
import com.elifkavurga.backend.notification.repository.NotificationLogRepository;
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

import static org.assertj.core.api.Assertions.assertThat;
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

    @Autowired
    private NotificationLogRepository notificationLogRepository;

    @Autowired
    private UserRepository userRepository;

    private Long testUserId;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        notificationLogRepository.deleteAll();
        repository.deleteAll();

        User user = new User();
        user.setEmail("emergency+" + System.nanoTime() + "@test.local");
        user.setPassword("test");
        user.setUsername("emergency-tester-" + System.nanoTime());
        testUserId = userRepository.save(user).getId();
    }

    @Test
    void startAndStatusFlowWorks() throws Exception {
        mvc.perform(post("/api/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": %d,
                                  "latitude": 41.0082,
                                  "longitude": 28.9784,
                                  "currentRiskLevel": "HIGH",
                                  "calledContactName": "112 Acil Cagri Merkezi",
                                  "calledPhoneNumber": "112",
                                  "sharedTo": ["anne", "kardes"]
                                }
                                """.formatted(testUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(true))
                .andExpect(jsonPath("$.data.userId").value(testUserId))
                .andExpect(jsonPath("$.data.currentRiskLevel").value("HIGH"))
                .andExpect(jsonPath("$.data.calledContactName").value("112 Acil Cagri Merkezi"))
                .andExpect(jsonPath("$.data.calledPhoneNumber").value("112"))
                .andExpect(jsonPath("$.data.sharedTo.length()").value(0));

        assertThat(repository.findAll())
                .singleElement()
                .satisfies(event -> {
                    assertThat(event.getCurrentRiskLevel()).isEqualTo("HIGH");
                    assertThat(event.getCalledContactName()).isEqualTo("112 Acil Cagri Merkezi");
                    assertThat(event.getCalledPhoneNumber()).isEqualTo("112");
                });

        mvc.perform(get("/emergency/status").param("userId", String.valueOf(testUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(true))
                .andExpect(jsonPath("$.data.latitude").value(41.0082))
                .andExpect(jsonPath("$.data.longitude").value(28.9784))
                .andExpect(jsonPath("$.data.calledPhoneNumber").value("112"));
    }

    @Test
    void stopMarksEventInactive() throws Exception {
        mvc.perform(post("/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": %d,
                                  "latitude": 41.0082,
                                  "longitude": 28.9784
                                }
                                """.formatted(testUserId)))
                .andExpect(status().isOk());

        mvc.perform(post("/emergency/stop")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": %d
                                }
                                """.formatted(testUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(false))
                .andExpect(jsonPath("$.data.endedAt").exists());

        mvc.perform(get("/emergency/status").param("userId", String.valueOf(testUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(false));
    }

    @Test
    void cannotStartSecondActiveEmergency() throws Exception {
        mvc.perform(post("/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": %d,
                                  "latitude": 41.0082,
                                  "longitude": 28.9784
                                }
                                """.formatted(testUserId)))
                .andExpect(status().isOk());

        mvc.perform(post("/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": %d,
                                  "latitude": 41.1,
                                  "longitude": 29.1
                                }
                                """.formatted(testUserId)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Kullanicinin zaten aktif bir acil durumu var"));
    }
}
