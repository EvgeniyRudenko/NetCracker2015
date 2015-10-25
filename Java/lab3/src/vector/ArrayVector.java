package vector;

public class ArrayVector implements Vector {

    protected double[] data;
    private int size;

    public ArrayVector(int size){
        if  (size<0)
            throw new IllegalArgumentException("Wrong size: " + size);
        this.size = size;
        this.data = new double[size];
    }

    public ArrayVector(double[] data) {
        this.size = data.length;
        this.data = new double[size];
        for (int i = 0; i < size; i++)
            this.data[i] = data[i];
    }

    public ArrayVector(ArrayVector arrayVector) {
        this.size = arrayVector.size;
        this.data = new double[size];
        for (int i = 0; i < size; i++)
            this.data[i] = arrayVector.data[i];
    }

    @Override
    public void fillFromMass(double[] data){
        this.size = data.length;
        this.data = new double[size];
        for (int i = 0; i < size; i++)
        this.data[i] = data[i];
    }

    @Override
    public void fillFromVector(ArrayVector arrayVector) {
        this.size = arrayVector.size;
        this.data = new double[size];
        for (int i = 0; i < size; i++)
            this.data[i] = arrayVector.data[i];
    }

    @Override
    public int getSize(){
        return size;
    }

    @Override
    public boolean equal(ArrayVector arrayVector){
        if (arrayVector.size!=size) return false;
        for (int i=0; i< size;i++)
            if (data[i] != arrayVector.data[i])
                return false;
        return true;
    }
    @Override
    public ArrayVector sum(ArrayVector arrayVector) throws IncompatibleVectorSizesException{
        if (arrayVector.size!=size) throw new IncompatibleVectorSizesException("Vectors have different sizes");
        for (int i=0; i< size;i++)
            data[i] += arrayVector.data[i];
        return this;
    }

    @Override
    public ArrayVector mult(double k){
        for (int i=0; i< size;i++)
            data[i] *= k;
        return this;
    }

    @Override
    public double getElement(int index){
        if (index<0 || index>size-1) throw new VectorIndexOutOfBoundsException("Incorrect index: " + index);
        return data[index];
    }

    @Override
    public void setElement(int index, double value){
        if (index<0 || index>size-1) throw new VectorIndexOutOfBoundsException ("Incorrect index: " + index);
            data[index]=value;
    }

    public double getMinElement(){
        double min = data[0];
        for (int i=1; i< size;i++)
            if (data[i] < min) min = data[i] ;
        return min;
    }

    public double getMaxElement(){
        double max = data[0];
        for (int i=1; i< size;i++)
            if (data[i] > max) max = data[i] ;
        return max;
    }

    public void sort(){
        Vectors.selectionSort(this);
    }

}
