
package com.myapp;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

// REMOVE 'public' here
class AppTest {

    @Test
    void testAdd() {
        App app = new App();
        assertEquals(5, app.add(2, 3));
    }
}
