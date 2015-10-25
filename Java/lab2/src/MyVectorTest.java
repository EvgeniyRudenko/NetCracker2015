import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.Arrays;

import static org.junit.Assert.*;

public class MyVectorTest {

    @Before
    public void setUp()  {

    }

    @After
    public void tearDown()  {

    }

    @Test
    public void testGetSize()  {
        double[] a = {0, 15, -22};
        MyVector vec = new MyVector(a);
        assertEquals(3, vec.getSize());
    }

    @Test
    public void testCompare()  {
        double[] a = {7, 77, -33, 0, -8.1};
        double[] b = {7, 77, -33, 0, -8.1};
        MyVector vec1 = new MyVector(a);
        MyVector vec2 = new MyVector(b);
        assertTrue(vec1.compare(vec2));
    }

    @Test
    public void testAdd()  {
        double[] a = {1, 2, -1, 0, -2};
        double[] b = {2, 4, -2, 0, -4};
        double[] c = {3, 6, -3, 0, -6};
        MyVector vecA = new MyVector(a);
        MyVector vecB = new MyVector(b);
        MyVector vec = vecA.add(vecB);
        for (int i = 0; i < a.length; i++) {
            assertEquals(c[i],vec.getElement(i),0.000001);
        }
    }

    @Test
    public void testMulti()  {
        double[] a = {1, 2, -1, 0, -2};
        double[] b = {2, 4, -2, 0, -4};
        MyVector vecA = new MyVector(a);
        MyVector vecB = vecA.multi(2);
        for (int i = 0; i < a.length; i++) {
            assertEquals(vecB.getElement(i),vecA.getElement(i),0.000001);
        }
    }

    @Test
    public void testGetElement()  {
        double[] a = {1, 7, -1, 0, 6.3};
        MyVector vec = new MyVector(a);
        assertEquals(6.3,vec.getElement(4),0.0000001);
    }

    @Test
    public void testSetElement()  {
        double[] a = {1, 7, -1, 0, 6.3};
        MyVector vec = new MyVector(a);
        vec.setElement(3, 5.5);
        assertEquals(5.5,vec.getElement(3),0.0000001);
    }

    @Test
    public void testGetMinElement()  {
        double[] a = {1, 3, -1, 5};
        MyVector vec = new MyVector(a);
        assertEquals(-1.0,vec.getMinElement(),0.0000001);
    }

    @Test
    public void testGetMaxElement()  {
        double[] a = {1, 3, -1, 5};
        MyVector vec = new MyVector(a);
        assertEquals(5.0,vec.getMaxElement(),0.0000001);
    }

    @Test
    public void testSort()  {
        double[] a = {1, 5, -1, 3, 8, -2, 7, 0};
        double[] b = {-2, -1, 0, 1, 3, 5, 7, 8};
        MyVector vec = new MyVector(a);
        vec.sort();
        for (int i = 0; i < a.length; i++) {
            assertEquals(b[i],vec.getElement(i),0.0000001);
        }
    }

    // fail methods

    // all of the methods end with 'F' and do not pass through the test

    @Test
    public void testGetSizeF()  {
        double[] a = {0, 15, -22};
        MyVector vec = new MyVector(a);
        assertEquals(2, vec.getSize());
    }

    @Test
    public void testCompareF()  {
        double[] a = {7, 77, -33, 0, -8.1};
        double[] b = {7, 77, -33, 0, 8.1};
        MyVector vec1 = new MyVector(a);
        MyVector vec2 = new MyVector(b);
        assertTrue(vec1.compare(vec2));
    }

    @Test
    public void testAddF()  {
        double[] a = {1, 2, -1, 0, -2};
        double[] b = {2, 4, -2, 0, -4};
        double[] c = {3, 6,  1, 0, -6};
        MyVector vecA = new MyVector(a);
        MyVector vecB = new MyVector(b);
        MyVector vec = vecA.add(vecB);
        for (int i = 0; i < a.length; i++) {
            assertEquals(c[i],vec.getElement(i),0.000001);
        }
    }

    @Test
    public void testMultiF()  {
        double[] a = {1, 2, -1, 0, -2};
        double[] b = {2, 4, -2, 0, 4};
        MyVector vecA = new MyVector(a);
        MyVector vecB = vecA.multi(2);
        for (int i = 0; i < a.length; i++) {
            assertEquals(vecB.getElement(i),vecA.getElement(i),0.000001);
        }
    }

    @Test
    public void testGetElementF()  {
        double[] a = {1, 7, -1, 0, 6.3};
        MyVector vec = new MyVector(a);
        assertEquals(1,vec.getElement(1),0.0000001);
    }

    @Test
    public void testSetElementF()  {
        double[] a = {1, 7, -1, 0, 6.3};
        MyVector vec = new MyVector(a);
        vec.setElement(3, 5.5);
        assertEquals(-1,vec.getElement(3),0.0000001);
    }

    @Test
    public void testGetMinElementF()  {
        double[] a = {1, 3, -1, 5};
        MyVector vec = new MyVector(a);
        assertEquals(1.0,vec.getMinElement(),0.0000001);
    }

    @Test
    public void testGetMaxElementF()  {
        double[] a = {1, 3, -1, 5};
        MyVector vec = new MyVector(a);
        assertEquals(3.0,vec.getMaxElement(),0.0000001);
    }

    @Test
    public void testSortF()  {
        double[] a = {1, 5, -1, 3, 8, -2, 7, 0};
        double[] b = {-2, -1, 0, 1, 5, 3, 7, 8};
        MyVector vec = new MyVector(a);
        vec.sort();
        for (int i = 0; i < a.length; i++) {
            assertEquals(b[i],vec.getElement(i),0.0000001);
        }
    }

}
