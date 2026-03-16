package com.elifkavurga.backend.notification;

import com.elifkavurga.backend.emergency.repository.EmergencyEventRepository;
import com.elifkavurga.backend.notification.repository.NotificationLogRepository;
import com.elifkavurga.backend.report.repository.ReportRepository;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.entity.UserRole;
import com.elifkavurga.backend.user.repository.UserRepository;
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
class NotificationLogIntegrationTest {

    private MockMvc mvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private EmergencyEventRepository emergencyEventRepository;

    @Autowired
    private NotificationLogRepository notificationLogRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ReportRepository reportRepository;

    private Long testUserId;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        notificationLogRepository.deleteAll();
        emergencyEventRepository.deleteAll();
        reportRepository.deleteAll();
        userRepository.deleteAll();

        User user = new User();
        user.setEmail("notification@test.local");
        user.setPassword("test");
        user.setPasswordHash("test");
        user.setFirstName("Notification");
        user.setLastName("Tester");
        user.setUsername("notification-tester");
        user.setRole(UserRole.USER);
        user.setIsActive(true);
        testUserId = userRepository.save(user).getId();
    }

    @Test
    void emergencyStartCreatesNotificationLogs() throws Exception {
        String response = mvc.perform(post("/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": %d,
                                  "latitude": 41.0082,
                                  "longitude": 28.9784,
                                  "sharedTo": ["905551112233", "905441112233"]
                                }
                                """.formatted(testUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id").exists())
                .andReturn()
                .getResponse()
                .getContentAsString();

        String eventId = response.replaceAll(".*\"id\":(\\d+).*", "$1");

        mvc.perform(get("/notifications/logs").param("eventId", eventId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(2))
                .andExpect(jsonPath("$.data[0].type").value("SMS"))
                .andExpect(jsonPath("$.data[0].status").value("SENT"));
    }

    @Test
    void emergencyStartWithCalledPhoneCreatesCallAndSmsLogs() throws Exception {
        String response = mvc.perform(post("/api/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": %d,
                                  "latitude": 41.0082,
                                  "longitude": 28.9784,
                                  "currentRiskLevel": "MEDIUM",
                                  "calledContactName": "Ayse Demir",
                                  "calledPhoneNumber": "905551112233",
                                  "sharedTo": ["905551112233", "905441112233"]
                                }
                                """.formatted(testUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id").exists())
                .andReturn()
                .getResponse()
                .getContentAsString();

        String eventId = response.replaceAll(".*\"id\":(\\d+).*", "$1");

        mvc.perform(get("/notifications/logs").param("eventId", eventId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(3))
                .andExpect(jsonPath("$.data[0].type").value("CALL"))
                .andExpect(jsonPath("$.data[0].to").value("905551112233"))
                .andExpect(jsonPath("$.data[1].type").value("SMS"))
                .andExpect(jsonPath("$.data[2].type").value("SMS"));
    }
}
