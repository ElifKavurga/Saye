package com.elifkavurga.backend.emergencycontact.repository;

import com.elifkavurga.backend.emergencycontact.entity.EmergencyContact;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface EmergencyContactRepository extends JpaRepository<EmergencyContact, Long> {

    List<EmergencyContact> findAllByUser_IdOrderByIsPrimaryDescCreatedAtAsc(Long userId);

    Optional<EmergencyContact> findByIdAndUser_Id(Long id, Long userId);

    Optional<EmergencyContact> findFirstByUser_IdAndIdNotOrderByCreatedAtAsc(Long userId, Long excludedId);

    Optional<EmergencyContact> findFirstByUser_IdOrderByCreatedAtAsc(Long userId);

    long countByUser_Id(Long userId);

    @Modifying
    @Transactional
    @Query("""
            update EmergencyContact contact
            set contact.isPrimary = false
            where contact.user.id = :userId
              and contact.id <> :contactId
              and contact.isPrimary = true
            """)
    int clearPrimaryForUser(@Param("userId") Long userId, @Param("contactId") Long contactId);
}
