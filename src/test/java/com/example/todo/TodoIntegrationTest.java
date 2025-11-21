package com.example.todo;

import com.example.todo.model.Todo;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class TodoIntegrationTest {

  @Autowired
  private TestRestTemplate rest;

  @Test
  void createAndList() {
    Todo t = new Todo();
    t.setTitle("Demo");
    t.setDescription("OpenTelemetry");
    t.setCompleted(false);

    ResponseEntity<Todo> created = rest.postForEntity("/api/todos", t, Todo.class);
    assertThat(created.getStatusCode().is2xxSuccessful()).isTrue();
    Todo body = created.getBody();
    assertThat(body).isNotNull();
    assertThat(body.getId()).isNotNull();

    Todo[] list = rest.getForObject("/api/todos", Todo[].class);
    assertThat(list).isNotEmpty();
  }
}