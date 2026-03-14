package com.elifkavurga.backend.emergencycontact.service;

import com.elifkavurga.backend.common.exceptions.ResourceNotFoundException;
import com.elifkavurga.backend.common.exceptions.UnauthorizedException;
import com.elifkavurga.backend.config.AppSecurityProperties;
import com.elifkavurga.backend.emergencycontact.dto.EmergencyContactRequest;
import com.elifkavurga.backend.emergencycontact.dto.EmergencyContactResponse;
import com.elifkavurga.backend.emergencycontact.entity.EmergencyContact;
import com.elifkavurga.backend.emergencycontact.repository.EmergencyContactRepository;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.entity.UserRole;
import com.elifkavurga.backend.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EmergencyContactServiceImpl implements EmergencyContactService {

    private static final String DEMO_EMAIL = "demo@example.com";
    private static final String DEMO_PASSWORD = "demo12345";
    private static final String DEMO_USERNAME = "demo-user";

    private final EmergencyContactRepository emergencyContactRepository;
    private final UserRepository userRepository;
    private final AppSecurityProperties appSecurityProperties;
    private final PasswordEncoder passwordEncoder;

    @Override
    public List<EmergencyContactResponse> listMine(String userIdHeader) {
        User currentUser = resolveCurrentUser(userIdHeader);
        return emergencyContactRepository.findAllByUserIdOrderByIsPrimaryDescCreatedAtAsc(currentUser.getId()).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public EmergencyContactResponse create(String userIdHeader, EmergencyContactRequest request) {
        User currentUser = resolveCurrentUser(userIdHeader);

        EmergencyContact emergencyContact = new EmergencyContact();
        emergencyContact.setUserId(currentUser.getId());
        emergencyContact.setName(request.getName().trim());
        emergencyContact.setPhoneNumber(request.getPhoneNumber().trim());

        boolean shouldBePrimary = Boolean.TRUE.equals(request.getIsPrimary())
                || emergencyContactRepository.countByUserId(currentUser.getId()) == 0;
        emergencyContact.setIsPrimary(shouldBePrimary);

        EmergencyContact saved = emergencyContactRepository.save(emergencyContact);
        if (shouldBePrimary) {
            emergencyContactRepository.clearPrimaryForUser(currentUser.getId(), saved.getId());
        }

        return toResponse(saved);
    }

    @Override
    @Transactional
    public EmergencyContactResponse update(String userIdHeader, Long contactId, EmergencyContactRequest request) {
        User currentUser = resolveCurrentUser(userIdHeader);
        EmergencyContact contact = getOwnedContact(contactId, currentUser.getId());

        contact.setName(request.getName().trim());
        contact.setPhoneNumber(request.getPhoneNumber().trim());
        contact.setIsPrimary(Boolean.TRUE.equals(request.getIsPrimary()));

        EmergencyContact saved = emergencyContactRepository.save(contact);
        if (Boolean.TRUE.equals(saved.getIsPrimary())) {
            emergencyContactRepository.clearPrimaryForUser(currentUser.getId(), saved.getId());
        } else {
            promotePrimaryIfNeeded(currentUser.getId(), saved.getId());
        }

        return toResponse(saved);
    }

    @Override
    @Transactional
    public void delete(String userIdHeader, Long contactId) {
        User currentUser = resolveCurrentUser(userIdHeader);
        EmergencyContact contact = getOwnedContact(contactId, currentUser.getId());
        boolean wasPrimary = Boolean.TRUE.equals(contact.getIsPrimary());

        emergencyContactRepository.delete(contact);
        if (wasPrimary) {
            promotePrimaryIfNeeded(currentUser.getId(), null);
        }
    }

    private EmergencyContact getOwnedContact(Long contactId, Long userId) {
        return emergencyContactRepository.findByIdAndUserId(contactId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Emergency contact not found"));
    }

    private void promotePrimaryIfNeeded(Long userId, Long excludedId) {
        List<EmergencyContact> contacts = emergencyContactRepository.findAllByUserIdOrderByIsPrimaryDescCreatedAtAsc(userId);
        boolean hasPrimary = contacts.stream().anyMatch(contact -> Boolean.TRUE.equals(contact.getIsPrimary()));
        if (hasPrimary) {
            return;
        }

        EmergencyContact nextPrimary = excludedId == null
                ? emergencyContactRepository.findFirstByUserIdOrderByCreatedAtAsc(userId).orElse(null)
                : emergencyContactRepository.findFirstByUserIdAndIdNotOrderByCreatedAtAsc(userId, excludedId).orElse(null);

        if (nextPrimary == null) {
            return;
        }

        nextPrimary.setIsPrimary(true);
        emergencyContactRepository.save(nextPrimary);
    }

    private User resolveCurrentUser(String userIdHeader) {
        if (!StringUtils.hasText(userIdHeader)) {
            if (!appSecurityProperties.isDemoLoginEnabled()) {
                throw new UnauthorizedException("X-USER-ID header is required");
            }
            return userRepository.findByEmail(DEMO_EMAIL).orElseGet(this::createDemoUser);
        }

        Long userId;
        try {
            userId = Long.parseLong(userIdHeader);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("X-USER-ID must be a valid number");
        }

        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found for X-USER-ID: " + userId));
    }

    private User createDemoUser() {
        User user = new User();
        user.setEmail(DEMO_EMAIL);
        user.setUsername(DEMO_USERNAME);
        user.setFirstName(DEMO_USERNAME);
        user.setLastName("-");
        user.setRole(UserRole.USER);
        String encodedPassword = passwordEncoder.encode(DEMO_PASSWORD);
        user.setPasswordHash(encodedPassword);
        user.setPassword(encodedPassword);
        user.setPhone(null);
        user.setIsActive(true);
        return userRepository.save(user);
    }

    private EmergencyContactResponse toResponse(EmergencyContact contact) {
        return EmergencyContactResponse.builder()
                .id(contact.getId())
                .userId(contact.getUserId())
                .name(contact.getName())
                .phoneNumber(contact.getPhoneNumber())
                .isPrimary(contact.getIsPrimary())
                .createdAt(contact.getCreatedAt())
                .updatedAt(contact.getUpdatedAt())
                .build();
    }
}
