package com.example.todo.service;

import com.example.todo.model.Todo;
import com.example.todo.repository.TodoRepository;
import io.micrometer.observation.annotation.Observed;
import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TodoService {
  private final TodoRepository repository;
  private final Tracer tracer = GlobalOpenTelemetry.get().getTracer("com.example.todo");

  public TodoService(TodoRepository repository) {
    this.repository = repository;
  }

  @Observed(name = "todo.findAll")
  public List<Todo> findAll() {
    return repository.findAll();
  }

  @Observed(name = "todo.findById")
  public Todo findById(Long id) {
    return repository.findById(id).orElseThrow();
  }

  @Observed(name = "todo.create")
  public Todo create(Todo todo) {
    Span span = tracer.spanBuilder("todo.create.manual").startSpan();
    try {
      return repository.save(todo);
    } finally {
      span.end();
    }
  }

  @Observed(name = "todo.update")
  public Todo update(Long id, Todo input) {
    Span span = tracer.spanBuilder("todo.update.manual").startSpan();
    Todo existing = repository.findById(id).orElseThrow();
    existing.setTitle(input.getTitle());
    existing.setDescription(input.getDescription());
    existing.setCompleted(input.isCompleted());
    try {
      return repository.save(existing);
    } finally {
      span.end();
    }
  }

  @Observed(name = "todo.delete")
  public void delete(Long id) {
    repository.deleteById(id);
  }

  @Observed(name = "todo.deleteAll")
  public void deleteAll() {
    repository.deleteAll();
  }
}