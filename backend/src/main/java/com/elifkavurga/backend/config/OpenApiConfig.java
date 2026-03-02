package com.elifkavurga.backend.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Saye Backend API")
                        .version("v1")
                        .description("Raporlama, acil durum ve bildirim logu endpointleri")
                        .contact(new Contact().name("Saye Backend Team")))
                .servers(List.of(new Server().url("/")));
    }
}
