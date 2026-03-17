package com.elifkavurga.backend.usersettings;

import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import com.elifkavurga.backend.usersettings.repository.UserSettingsRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
class UserSettingsControllerIntegrationTest {

    private MockMvc mvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private UserSettingsRepository userSettingsRepository;

    @Autowired
    private UserRepository userRepository;

    private Long testUserId;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        userSettingsRepository.deleteAll();
        testUserId = userRepository.save(buildUser("settings-owner")).getId();
    }

    @Test
    void getCreatesDefaultSettingsWhenMissing() throws Exception {
        mvc.perform(get("/api/settings/me")
                        .header("X-USER-ID", testUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.userId").value(testUserId))
                .andExpect(jsonPath("$.data.profileVisible").value(true))
                .andExpect(jsonPath("$.data.locationTrackingEnabled").value(true))
                .andExpect(jsonPath("$.data.backgroundRefreshEnabled").value(true))
                .andExpect(jsonPath("$.data.bluetoothEnabled").value(true))
                .andExpect(jsonPath("$.data.gsmSmsEnabled").value(false))
                .andExpect(jsonPath("$.data.quickUnlockAccessEnabled").value(false));
    }

    @Test
    void updatePersistsOwnSettings() throws Exception {
        mvc.perform(put("/api/settings/me")
                        .header("X-USER-ID", testUserId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "profileVisible": false,
                                  "locationTrackingEnabled": false,
                                  "backgroundRefreshEnabled": true,
                                  "bluetoothEnabled": false,
                                  "gsmSmsEnabled": true,
                                  "quickUnlockAccessEnabled": true
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.userId").value(testUserId))
                .andExpect(jsonPath("$.data.profileVisible").value(false))
                .andExpect(jsonPath("$.data.locationTrackingEnabled").value(false))
                .andExpect(jsonPath("$.data.backgroundRefreshEnabled").value(true))
                .andExpect(jsonPath("$.data.bluetoothEnabled").value(false))
                .andExpect(jsonPath("$.data.gsmSmsEnabled").value(true))
                .andExpect(jsonPath("$.data.quickUnlockAccessEnabled").value(true));

        mvc.perform(get("/api/settings/me")
                        .header("X-USER-ID", testUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.profileVisible").value(false))
                .andExpect(jsonPath("$.data.locationTrackingEnabled").value(false))
                .andExpect(jsonPath("$.data.backgroundRefreshEnabled").value(true))
                .andExpect(jsonPath("$.data.bluetoothEnabled").value(false))
                .andExpect(jsonPath("$.data.gsmSmsEnabled").value(true))
                .andExpect(jsonPath("$.data.quickUnlockAccessEnabled").value(true));
    }

    private User buildUser(String usernamePrefix) {
        User user = new User();
        String uniqueUsername = usernamePrefix + "-" + System.nanoTime();
        user.setEmail(usernamePrefix + "+" + System.nanoTime() + "@test.local");
        user.setPassword("test");
        user.setUsername(uniqueUsername);
        user.setPhone("05550000000");
        return user;
    }
}
