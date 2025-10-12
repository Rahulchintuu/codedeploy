package com.myapp;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class AppTest {

    @Test
    void testGreet() {
        App app = new App();
        assertEquals("Hello", app.greet());
    }
}
