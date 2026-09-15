package com.sb.erp.apct.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sb.erp.apct.repository.ApplicantRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class StatisticsSyncService {

    private final ApplicantRepository applicantRepository;
    private final ObjectMapper objectMapper;

    private final RestTemplate restTemplate = new RestTemplate();

    // 기존 대시보드용
    public void sendApplicantStatisticsToDjango(Long comId) {

        String djangoUrl =
                "http://localhost:8000/dashboard/api/statistics/";

        List<Object[]> results =
                applicantRepository.countByStatusGrouped(comId);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        for (Object[] row : results) {

            String status = (String) row[0];
            Number count = (Number) row[1];

            Map<String, Object> payload = new HashMap<>();
            payload.put("date", java.time.LocalDate.now().toString());
            payload.put("category", status);
            payload.put("count", count.intValue());

            try {
                String json = objectMapper.writeValueAsString(payload);

                HttpEntity<String> request = new HttpEntity<>(json, headers);

                restTemplate.postForEntity(djangoUrl, request, String.class);

            } catch (Exception e) {
                throw new RuntimeException("Django 통계 전송 실패", e);
            }
        }
    }

    // 분석용
    public Map<String, Object> getApplicantAnalysisFromDjango(Long comId) {

        List<Object[]> statusResults =
                applicantRepository.countByStatusGrouped(comId);

        List<Object[]> monthResults =
                applicantRepository.countByMonthGrouped(comId);

        List<Map<String, Object>> statusCounts = new ArrayList<>();
        for (Object[] row : statusResults) {
            Map<String, Object> item = new HashMap<>();
            item.put("status", (String) row[0]);
            item.put("count", ((Number) row[1]).intValue());
            statusCounts.add(item);
        }

        List<Map<String, Object>> monthlyCounts = new ArrayList<>();
        for (Object[] row : monthResults) {
            Map<String, Object> item = new HashMap<>();
            item.put("month", (String) row[0]);
            item.put("count", ((Number) row[1]).intValue());
            monthlyCounts.add(item);
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("statusCounts", statusCounts);
        payload.put("monthlyCounts", monthlyCounts);

        String djangoUrl =
                "http://localhost:8000/dashboard/api/analysis/";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        try {
            String json = objectMapper.writeValueAsString(payload);

            HttpEntity<String> request = new HttpEntity<>(json, headers);

            ResponseEntity<Map> response =
                    restTemplate.postForEntity(djangoUrl, request, Map.class);

            return response.getBody();

        } catch (Exception e) {
            throw new RuntimeException("Django 분석 요청 실패", e);
        }
    }
}