package com.elifkavurga.backend.map.service;

import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

@Service
public class RiskClusterService {

    private static final double CLUSTER_DISTANCE_METERS = 250.0;

    public List<RiskCluster> clusterReports(List<NearbyReportProjection> reports) {
        List<NearbyReportProjection> validReports = reports.stream()
                .filter(report -> report.getLatitude() != null && report.getLongitude() != null)
                .toList();
        List<RiskCluster> clusters = new ArrayList<>();
        Set<Integer> visited = new HashSet<>();

        for (int i = 0; i < validReports.size(); i++) {
            if (visited.contains(i)) {
                continue;
            }

            MutableRiskCluster cluster = new MutableRiskCluster();
            List<Integer> queue = new ArrayList<>();
            queue.add(i);
            visited.add(i);

            for (int cursor = 0; cursor < queue.size(); cursor++) {
                int currentIndex = queue.get(cursor);
                NearbyReportProjection current = validReports.get(currentIndex);
                cluster.add(current);

                for (int candidateIndex = 0; candidateIndex < validReports.size(); candidateIndex++) {
                    if (visited.contains(candidateIndex)) {
                        continue;
                    }

                    NearbyReportProjection candidate = validReports.get(candidateIndex);
                    double distance = distanceMeters(
                            current.getLatitude(),
                            current.getLongitude(),
                            candidate.getLatitude(),
                            candidate.getLongitude()
                    );
                    if (distance <= CLUSTER_DISTANCE_METERS) {
                        visited.add(candidateIndex);
                        queue.add(candidateIndex);
                    }
                }
            }

            clusters.add(cluster.toCluster());
        }

        return clusters;
    }

    private double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
        double earthRadiusMeters = 6_371_000.0;
        double lat1Rad = Math.toRadians(lat1);
        double lat2Rad = Math.toRadians(lat2);
        double deltaLatRad = Math.toRadians(lat2 - lat1);
        double deltaLonRad = Math.toRadians(lon2 - lon1);

        double a = Math.sin(deltaLatRad / 2) * Math.sin(deltaLatRad / 2)
                + Math.cos(lat1Rad) * Math.cos(lat2Rad)
                * Math.sin(deltaLonRad / 2) * Math.sin(deltaLonRad / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadiusMeters * c;
    }

    private static final class MutableRiskCluster {
        private final List<NearbyReportProjection> reports = new ArrayList<>();
        private double latitudeTotal;
        private double longitudeTotal;

        void add(NearbyReportProjection report) {
            reports.add(report);
            latitudeTotal += report.getLatitude();
            longitudeTotal += report.getLongitude();
        }

        double getCenterLatitude() {
            return latitudeTotal / reports.size();
        }

        double getCenterLongitude() {
            return longitudeTotal / reports.size();
        }

        RiskCluster toCluster() {
            double centerLatitude = getCenterLatitude();
            double centerLongitude = getCenterLongitude();
            String clusterId = String.format(
                    Locale.US,
                    "cluster-%.6f-%.6f",
                    centerLatitude,
                    centerLongitude
            );
            return new RiskCluster(
                    clusterId,
                    centerLatitude,
                    centerLongitude,
                    List.copyOf(reports)
            );
        }
    }
}
