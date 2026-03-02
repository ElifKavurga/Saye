package com.elifkavurga.backend.report.dto;

import lombok.Getter;
import lombok.Setter;

import jakarta.validation.constraints.NotNull;
import io.swagger.v3.oas.annotations.media.Schema;
import java.io.Serializable;

@Getter
@Setter
@Schema(description = "Yeni durum bildirimi istegi")
public class ReportRequest implements Serializable {
    // user id optional
    @Schema(description = "Bildirimi gonderen kullanici id", example = "30")
    private Long userId;

    @NotNull
    @Schema(description = "Bildirim kategorisi", example = "SUC", allowableValues = {"SUC", "TAKIP", "HAYVAN", "SAGLIK", "ARIZA", "TRAFIK"})
    private String category;

    @Schema(description = "Opsiyonel aciklama", example = "Parkta supheli bir durum var")
    private String description;

    @Schema(description = "Enlem", example = "41.0082")
    private Double latitude;
    @Schema(description = "Boylam", example = "28.9784")
    private Double longitude;
}
