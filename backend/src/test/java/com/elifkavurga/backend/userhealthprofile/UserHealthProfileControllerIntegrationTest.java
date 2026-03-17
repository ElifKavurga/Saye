package com.elifkavurga.backend.userhealthprofile;

import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import com.elifkavurga.backend.userhealthprofile.repository.UserHealthProfileRepository;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
class UserHealthProfileControllerIntegrationTest {

    private MockMvc mvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserHealthProfileRepository userHealthProfileRepository;

    private Long testUserId;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        userHealthProfileRepository.deleteAll();
        testUserId = userRepository.save(buildUser("health-owner")).getId();
    }

    @Test
    void getCreatesEmptyProfileWhenMissing() throws Exception {
        mvc.perform(get("/api/health-profile/me")
                        .header("X-USER-ID", testUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.userId").value(testUserId))
                .andExpect(jsonPath("$.data.id").exists());
    }

    @Test
    void updatePersistsHealthProfile() throws Exception {
        mvc.perform(put("/api/health-profile/me")
                        .header("X-USER-ID", testUserId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "bloodType": "A Rh+",
                                  "allergyNotes": "Penisilin",
                                  "emergencyNote": "Astim ilaci cantada"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.userId").value(testUserId))
                .andExpect(jsonPath("$.data.bloodType").value("A Rh+"))
                .andExpect(jsonPath("$.data.allergyNotes").value("Penisilin"))
                .andExpect(jsonPath("$.data.emergencyNote").value("Astim ilaci cantada"));

        mvc.perform(put("/api/health-profile/me")
                        .header("X-USER-ID", testUserId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "bloodType": "0 Rh-",
                                  "allergyNotes": "Lateks",
                                  "emergencyNote": "Ikinci guncelleme"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.userId").value(testUserId))
                .andExpect(jsonPath("$.data.bloodType").value("0 Rh-"))
                .andExpect(jsonPath("$.data.allergyNotes").value("Lateks"))
                .andExpect(jsonPath("$.data.emergencyNote").value("Ikinci guncelleme"));

        mvc.perform(get("/api/health-profile/me")
                        .header("X-USER-ID", testUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.bloodType").value("0 Rh-"))
                .andExpect(jsonPath("$.data.allergyNotes").value("Lateks"))
                .andExpect(jsonPath("$.data.emergencyNote").value("Ikinci guncelleme"));

        assertThat(userHealthProfileRepository.count()).isEqualTo(1);
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
