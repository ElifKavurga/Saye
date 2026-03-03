package com.elifkavurga.backend.emergency;

import com.elifkavurga.backend.emergency.repository.EmergencyEventRepository;
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
class EmergencyControllerIntegrationTest {

    private MockMvc mvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private EmergencyEventRepository repository;

    @Autowired
    private UserRepository userRepository;

    private Long testUserId;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        repository.deleteAll();

        User user = new User();
        user.setEmail("emergency+" + System.nanoTime() + "@test.local");
        user.setPassword("test");
        user.setPasswordHash("test");
        user.setFirstName("Emergency");
        user.setLastName("Tester");
        user.setUsername("emergency-tester");
        user.setRole(UserRole.USER);
        user.setIsActive(true);
        testUserId = userRepository.save(user).getId();
    }

    @Test
    void startAndStatusFlowWorks() throws Exception {
        mvc.perform(post("/emergency/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": %d,
                                  "latitude": 41.0082,
                                  "longitude": 28.9784,
                                  "sharedTo": ["anne", "kardes"]
                                }
                                """.formatted(testUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active").value(true))
                .andExpect(jsonPath("$.data.userId").value(testUserId))
                .andExpect(jsonPath("$.data.sharedTo.length()").value(2));

        mvc.perform(get("/emergency/status").param("userId", String.valueOf(testUserId)))
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
