package com.elifkavurga.backend.emergencycontact.service;

import com.elifkavurga.backend.common.exceptions.ResourceNotFoundException;
import com.elifkavurga.backend.emergencycontact.dto.EmergencyContactRequest;
import com.elifkavurga.backend.emergencycontact.dto.EmergencyContactResponse;
import com.elifkavurga.backend.emergencycontact.entity.EmergencyContact;
import com.elifkavurga.backend.emergencycontact.repository.EmergencyContactRepository;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import com.elifkavurga.backend.user.service.CurrentUserResolver;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EmergencyContactServiceImpl implements EmergencyContactService {

    private final EmergencyContactRepository emergencyContactRepository;
    private final UserRepository userRepository;
    private final CurrentUserResolver currentUserResolver;

    @Override
    @Transactional
    public List<EmergencyContactResponse> listMine(String userIdHeader) {
        User currentUser = currentUserResolver.resolve(userIdHeader);
        return emergencyContactRepository.findAllByUser_IdOrderByIsPrimaryDescCreatedAtAsc(currentUser.getId()).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public EmergencyContactResponse create(String userIdHeader, EmergencyContactRequest request) {
        User currentUser = currentUserResolver.resolve(userIdHeader);
        User user = findUserById(currentUser.getId());

        EmergencyContact emergencyContact = new EmergencyContact();
        emergencyContact.setUser(user);
        emergencyContact.setName(request.getName().trim());
        emergencyContact.setPhoneNumber(request.getPhoneNumber().trim());

        boolean shouldBePrimary = Boolean.TRUE.equals(request.getIsPrimary())
                || emergencyContactRepository.countByUser_Id(user.getId()) == 0;
        emergencyContact.setIsPrimary(shouldBePrimary);

        EmergencyContact saved = emergencyContactRepository.save(emergencyContact);
        if (shouldBePrimary) {
            emergencyContactRepository.clearPrimaryForUser(user.getId(), saved.getId());
        }

        return toResponse(saved);
    }

    @Override
    @Transactional
    public EmergencyContactResponse update(String userIdHeader, Long contactId, EmergencyContactRequest request) {
        User currentUser = currentUserResolver.resolve(userIdHeader);
        User user = findUserById(currentUser.getId());
        EmergencyContact contact = getOwnedContact(contactId, currentUser.getId());

        contact.setUser(user);
        contact.setName(request.getName().trim());
        contact.setPhoneNumber(request.getPhoneNumber().trim());
        contact.setIsPrimary(Boolean.TRUE.equals(request.getIsPrimary()));

        EmergencyContact saved = emergencyContactRepository.save(contact);
        if (Boolean.TRUE.equals(saved.getIsPrimary())) {
            emergencyContactRepository.clearPrimaryForUser(user.getId(), saved.getId());
        } else {
            promotePrimaryIfNeeded(user.getId(), saved.getId());
        }

        return toResponse(saved);
    }

    @Override
    @Transactional
    public void delete(String userIdHeader, Long contactId) {
        User currentUser = currentUserResolver.resolve(userIdHeader);
        EmergencyContact contact = getOwnedContact(contactId, currentUser.getId());
        boolean wasPrimary = Boolean.TRUE.equals(contact.getIsPrimary());

        emergencyContactRepository.delete(contact);
        if (wasPrimary) {
            promotePrimaryIfNeeded(currentUser.getId(), null);
        }
    }

    private EmergencyContact getOwnedContact(Long contactId, Long userId) {
        return emergencyContactRepository.findByIdAndUser_Id(contactId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Emergency contact not found"));
    }

    private User findUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
    }

    private void promotePrimaryIfNeeded(Long userId, Long excludedId) {
        List<EmergencyContact> contacts = emergencyContactRepository.findAllByUser_IdOrderByIsPrimaryDescCreatedAtAsc(userId);
        boolean hasPrimary = contacts.stream().anyMatch(contact -> Boolean.TRUE.equals(contact.getIsPrimary()));
        if (hasPrimary) {
            return;
        }

        EmergencyContact nextPrimary = excludedId == null
                ? emergencyContactRepository.findFirstByUser_IdOrderByCreatedAtAsc(userId).orElse(null)
                : emergencyContactRepository.findFirstByUser_IdAndIdNotOrderByCreatedAtAsc(userId, excludedId).orElse(null);

        if (nextPrimary == null) {
            return;
        }

        nextPrimary.setIsPrimary(true);
        emergencyContactRepository.save(nextPrimary);
    }

    private EmergencyContactResponse toResponse(EmergencyContact contact) {
        return EmergencyContactResponse.builder()
                .id(contact.getId())
                .userId(contact.getUser().getId())
                .name(contact.getName())
                .phoneNumber(contact.getPhoneNumber())
                .isPrimary(contact.getIsPrimary())
                .createdAt(contact.getCreatedAt())
                .updatedAt(contact.getUpdatedAt())
                .build();
    }
}
