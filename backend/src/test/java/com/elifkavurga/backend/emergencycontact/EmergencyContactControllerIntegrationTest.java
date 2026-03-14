package com.elifkavurga.backend.emergencycontact;

import com.elifkavurga.backend.emergencycontact.entity.EmergencyContact;
import com.elifkavurga.backend.emergencycontact.repository.EmergencyContactRepository;
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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
class EmergencyContactControllerIntegrationTest {

    private MockMvc mvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private EmergencyContactRepository emergencyContactRepository;

    @Autowired
    private UserRepository userRepository;

    private Long testUserId;
    private Long anotherUserId;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context).build();
        emergencyContactRepository.deleteAll();

        testUserId = userRepository.save(buildUser("contact-owner")).getId();
        anotherUserId = userRepository.save(buildUser("another-owner")).getId();
    }

    @Test
    void createUpdateListAndDeleteFlowWorks() throws Exception {
        mvc.perform(post("/api/emergency-contacts")
                        .header("X-USER-ID", testUserId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "Ayse Demir",
                                  "phoneNumber": "05551112233",
                                  "isPrimary": true
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.userId").value(testUserId))
                .andExpect(jsonPath("$.data.name").value("Ayse Demir"))
                .andExpect(jsonPath("$.data.isPrimary").value(true));

        mvc.perform(post("/api/emergency-contacts")
                        .header("X-USER-ID", testUserId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "Mehmet Kaya",
                                  "phoneNumber": "05554445566",
                                  "isPrimary": false
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.isPrimary").value(false));

        Long secondContactId = emergencyContactRepository.findAllByUserIdOrderByIsPrimaryDescCreatedAtAsc(testUserId).stream()
                .filter(contact -> "Mehmet Kaya".equals(contact.getName()))
                .findFirst()
                .map(EmergencyContact::getId)
                .orElseThrow();

        mvc.perform(put("/api/emergency-contacts/{id}", secondContactId)
                        .header("X-USER-ID", testUserId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "Mehmet Kaya",
                                  "phoneNumber": "05554445566",
                                  "isPrimary": true
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id").value(secondContactId))
                .andExpect(jsonPath("$.data.isPrimary").value(true));

        mvc.perform(get("/api/emergency-contacts")
                        .header("X-USER-ID", testUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(2))
                .andExpect(jsonPath("$.data[0].id").value(secondContactId))
                .andExpect(jsonPath("$.data[0].isPrimary").value(true))
                .andExpect(jsonPath("$.data[1].isPrimary").value(false));

        mvc.perform(delete("/api/emergency-contacts/{id}", secondContactId)
                        .header("X-USER-ID", testUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        mvc.perform(get("/api/emergency-contacts")
                        .header("X-USER-ID", testUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].name").value("Ayse Demir"))
                .andExpect(jsonPath("$.data[0].isPrimary").value(true));
    }

    @Test
    void cannotAccessAnotherUsersContact() throws Exception {
        EmergencyContact contact = new EmergencyContact();
        contact.setUserId(anotherUserId);
        contact.setName("Gizli Kisi");
        contact.setPhoneNumber("05550000000");
        contact.setIsPrimary(true);
        Long contactId = emergencyContactRepository.save(contact).getId();

        mvc.perform(put("/api/emergency-contacts/{id}", contactId)
                        .header("X-USER-ID", testUserId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "Gizli Kisi",
                                  "phoneNumber": "05550000000",
                                  "isPrimary": true
                                }
                                """))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Emergency contact not found"));
    }

    private User buildUser(String usernamePrefix) {
        User user = new User();
        user.setEmail(usernamePrefix + "+" + System.nanoTime() + "@test.local");
        user.setPassword("test");
        user.setPasswordHash("test");
        user.setFirstName("Test");
        user.setLastName("User");
        user.setUsername(usernamePrefix);
        user.setRole(UserRole.USER);
        user.setPhone("05550000000");
        user.setIsActive(true);
        return user;
    }
}
