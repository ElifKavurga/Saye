package com.elifkavurga.backend.emergency.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Getter
@Setter
@Schema(description = "Acil durum baslatma istegi")
public class EmergencyStartRequest {
    @NotNull
    @Schema(description = "Acil durumu baslatan kullanici", example = "42")
    private Long userId;

    @NotNull
    @Schema(description = "Baslangic enlemi", example = "41.0082")
    private Double latitude;

    @NotNull
    @Schema(description = "Baslangic boylami", example = "28.9784")
    private Double longitude;

    @Schema(description = "Acil durum baslatildiginda istemcideki risk seviyesi", example = "HIGH")
    private String currentRiskLevel;

    @ArraySchema(schema = @Schema(example = "905551112233"), arraySchema = @Schema(description = "Bildirim gonderilecek acil kontaklar"))
    private List<String> sharedTo;
}
