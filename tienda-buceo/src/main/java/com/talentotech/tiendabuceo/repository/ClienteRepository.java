package com.talentotech.tiendabuceo.repository;

import com.talentotech.tiendabuceo.model.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {}
