package com.example.todo.controller;

import com.example.todo.model.Todo;
import com.example.todo.service.TodoService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/todos")
public class TodoController {
  private final TodoService service;

  public TodoController(TodoService service) {
    this.service = service;
  }

  @GetMapping
  public List<Todo> all() {
    return service.findAll();
  }

  @GetMapping("/{id}")
  public Todo one(@PathVariable Long id) {
    return service.findById(id);
  }

  @PostMapping
  public ResponseEntity<Todo> create(@RequestBody Todo todo) {
    Todo created = service.create(todo);
    return ResponseEntity.created(URI.create("/api/todos/" + created.getId())).body(created);
  }

  @PutMapping("/{id}")
  public Todo update(@PathVariable Long id, @RequestBody Todo todo) {
    return service.update(id, todo);
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> delete(@PathVariable Long id) {
    service.delete(id);
    return ResponseEntity.noContent().build();
  }

  @DeleteMapping
  public ResponseEntity<Void> deleteAll() {
    service.deleteAll();
    return ResponseEntity.noContent().build();
  }
}