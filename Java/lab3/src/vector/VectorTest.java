package vector;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author drnewman
 */
public class VectorTest {

    public VectorTest() {
    }

    @BeforeClass
    public static void setUpClass() {
    }

    @AfterClass
    public static void tearDownClass() {
    }

    /**
     * Test of setElement method, of class Vector.
     */
    @Test
    public void testSetElement() {
        System.out.println("setElement");
        // Arrange
        int index = 3;
        double value = 0.7;
        VectorImpl instance = new VectorImpl(5);
        // Act
        instance.setElement(index, value);
        // Assert
        assertEquals(value, instance.getData()[index], 0.0);
    }

    @Test(expected = VectorIndexOutOfBoundsException.class)
    public void testSetElementException1() {
        System.out.println("setElementException (index < 0)");
        // Arrange
        int index = -5;
        double value = 0.7;
        VectorImpl instance = new VectorImpl(5);
        // Act
        instance.setElement(index, value);
        // Assert

    }

    @Test(expected = VectorIndexOutOfBoundsException.class)
    public void testSetElementException2() {
        System.out.println("setElementException (index > size)");
        // Arrange
        int index = 5;
        double value = 0.7;
        VectorImpl instance = new VectorImpl(5);
        // Act
        instance.setElement(index, value);
        // Assert

    }

    /**
     * Test of getElement method, of class Vector.
     */
    @Test
    public void testGetElement() {
        System.out.println("getElement");
        // Arrange
        int index = 3;
        VectorImpl instance = new VectorImpl(5);
        double expResult = 0.7;
        instance.getData()[index] = expResult;
        // Act
        double result = instance.getElement(index);
        // Assert
        assertEquals(expResult, result, 0.0);
    }

    @Test(expected = VectorIndexOutOfBoundsException.class)
    public void testGetElementExeption1() {
        System.out.println("getElementExeption (index < 0)");
        // Arrange
        int index = -5;
        VectorImpl instance = new VectorImpl(5);
        double expResult = 0.7;
        // Act
        double result = instance.getElement(index);
        // Assert

    }

    @Test(expected = VectorIndexOutOfBoundsException.class)
    public void testGetElementExeption2() {
        System.out.println("getElementExeption (index > size)");
        // Arrange
        int index = 5;
        VectorImpl instance = new VectorImpl(5);
        double expResult = 0.7;
        // Act
        double result = instance.getElement(index);
        // Assert

    }

    /**
     * Test of getSize method, of class Vector.
     */
    @Test
    public void testGetSize() {
        System.out.println("getSize");
        // Arrange
        int expResult = 5;
        VectorImpl instance = new VectorImpl(expResult);
        int expResult2 = 0;
        VectorImpl instance2 = new VectorImpl(expResult2);
        // Act
        int result = instance.getSize();
        int result2 = instance2.getSize();
        // Assert
        assertEquals(expResult, result);
        assertEquals(expResult2, result2);
    }

    /**
     * Test of fillFromMass method, of class Vector.
     */
    @Test
    public void testFillFromMass() {
        System.out.println("fillFromMass");
        // Arrange
        double[] mass0 = {0.0, 0.9, -6.4, 8, -0.4};
        double[] mass = {5.0, -2.9, 0.0, -50000, 9};
        double[] mass2 = {5.0, -2.9, 0.0};
        double[] mass3 = {5.0, -2.9, 0.0, -50000, 9, 0.6};
        VectorImpl instance = new VectorImpl(5);
        instance.setData(mass0);
        VectorImpl instance2 = new VectorImpl(3);
        instance.setData(mass0);
        VectorImpl instance3 = new VectorImpl(6);
        instance.setData(mass0);
        // Act
        instance.fillFromMass(mass);
        instance2.fillFromMass(mass2);
        instance3.fillFromMass(mass3);
        // Assert
        assertArrayEquals(mass, instance.getData(), 0.0);
        assertArrayEquals(mass2, instance2.getData(), 0.0);
        assertArrayEquals(mass3, instance3.getData(), 0.0);
    }

    /**
     * Test of fillFromVector method, of class Vector.
     */
    @Test
    public void testFillFromVector() {
        System.out.println("fillFromVector");
        // Arrange
        double[] mass0 = {0.0, 0.9, -6.4, 8, -0.4};
        double[] mass = {5.0, -2.9, 0.0, -50000, 9};
        double[] mass2 = {5.0, -2.9, 0.0};
        double[] mass3 = {5.0, -2.9, 0.0, -50000, 9, 0.6};
        VectorImpl instance = new VectorImpl(5);
        instance.setData(mass0);
        VectorImpl vector = new VectorImpl(5);
        vector.setData(mass);
        VectorImpl instance2 = new VectorImpl(5);
        instance2.setData(mass0);
        VectorImpl vector2 = new VectorImpl(3);
        vector2.setData(mass2);
        VectorImpl instance3 = new VectorImpl(5);
        instance3.setData(mass0);
        VectorImpl vector3 = new VectorImpl(6);
        vector3.setData(mass3);
        // Act
        instance.fillFromVector(vector);
        instance2.fillFromVector(vector2);
        instance3.fillFromVector(vector3);
        // Assert
        assertArrayEquals(mass, instance.getData(), 0.0);
        assertArrayEquals(mass2, instance2.getData(), 0.0);
        assertArrayEquals(mass3, instance3.getData(), 0.0);
    }

    /**
     * Test of mult method, of class Vector.
     */
    @Test
    public void testMult() {
        System.out.println("mult");
        // Arrange
        double[] mass = {5.0, -2.9, 0.0, -50000, 9};
        double[] resultMass = {10.0, -5.8, 0.0, -100000, 18};
        VectorImpl instance = new VectorImpl(5);
        instance.setData(mass);
        double number = 2;
        // Act
        instance.mult(number);
        // Assert
        assertArrayEquals(resultMass, instance.getData(),  0.00000000001);
    }

    /**
     * Test of sum method, of class Vector.
     */
    @Test
    public void testSum() {
        System.out.println("sum");
        // Arrange
        double[] mass = {5.0, -2.9, 0.0, -50000, 9};
        double[] newMass = {1.1, 0.9, -6.4, 100, -9.4};
        double[] resultMass = {6.1, -2.0, -6.4, -49900, -0.4};
        VectorImpl instance = new VectorImpl(5);
        instance.setData(mass);
        VectorImpl vector = new VectorImpl(5);
        vector.setData(newMass);
        // Act
        try {
            instance.sum(vector);
        } catch (IncompatibleVectorSizesException ex) {
            fail("IncompatibleVectorSizesException");
        }
        // Assert
        assertArrayEquals(resultMass, instance.getData(), 0.00000000001);
    }

    @Test(expected = IncompatibleVectorSizesException.class)
    public void testSumException1() throws IncompatibleVectorSizesException{
        System.out.println("sumException (vector sizes > new vector sizes)");
        // Arrange
        double[] mass = {5.0, -2.9, 0.0, -50000, 9};
        double[] newMass = {1.1, 0.9, -6.4};
        VectorImpl instance = new VectorImpl(5);
        instance.setData(mass);
        VectorImpl vector = new VectorImpl(3);
        vector.setData(newMass);
        // Act
        instance.sum(vector);
        // Assert
    }

    @Test(expected = IncompatibleVectorSizesException.class)
    public void testSumException2() throws IncompatibleVectorSizesException{
        System.out.println("sumException (vector sizes < new vector sizes)");
        // Arrange
        double[] mass = {5.0, -2.9, 0.0, -50000, 9};
        double[] newMass = {1.1, 0.9, -6.4, 100, -9.4, 99};
        VectorImpl instance = new VectorImpl(5);
        instance.setData(mass);
        VectorImpl vector = new VectorImpl(6);
        vector.setData(newMass);
        // Act
        instance.sum(vector);
        // Assert
    }

    /**
     * Test of equal method, of class Vector.
     */
    @Test
    public void testEqual() {
        System.out.println("equal");
        // Arrange
        double[] original = {5.0, -2.9, 0.0, -50000, 9};
        double[] originalCopy = {5.0, -2.9, 0.0, -50000, 9};
        double[] mass1 = {0.0, 0.9, -6.4, 8, -0.4};
        double[] mass2 = {5.0, -2.9};
        double[] mass3 = {5.0, -2.9, 0.0, -50000, 9, 5.0, -2.9};

        VectorImpl instance = new VectorImpl(5);
        instance.setData(original);
        VectorImpl vector0 = new VectorImpl(5);
        vector0.setData(originalCopy);
        VectorImpl vector1 = new VectorImpl(5);
        vector1.setData(mass1);
        VectorImpl vector2 = new VectorImpl(2);
        vector2.setData(mass2);
        VectorImpl vector3 = new VectorImpl(7);
        vector3.setData(mass3);
        // Act
        boolean result0 = instance.equal(vector0);
        boolean result1 = instance.equal(vector1);
        boolean result2 = instance.equal(vector2);
        boolean result3 = instance.equal(vector3);
        // Assert
        assertTrue(result0);
        assertFalse(result1);
        assertFalse(result2);
        assertFalse(result3);
    }

    public class VectorImpl extends ArrayVector {

        public VectorImpl(int size) {
            super(size);
        }

        public double[] getData() {
            return super.data;
        }

        public void setData(double[] data) {
            super.data = data;
        }

    }

}
