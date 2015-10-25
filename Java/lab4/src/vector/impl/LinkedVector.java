package vector.impl;

import vector.IncompatibleVectorSizesException;

import vector.Vector;
import vector.VectorIndexOutOfBoundsException;

public class LinkedVector implements Vector, Cloneable{

    public class Nod {
        public double element;
        public Nod next;
        public Nod prev;

        public Nod() {
            this(0);
        }

        public Nod(double element) {
            this.element = element;
        }
    }

    protected Nod head;
    protected int size;

    protected Nod goToElement(int index) {
        Nod result = head;
        int i=0;
        while (i != index) {
            result = result.next;
            i++;
        }
        return result;
    }

    protected void insertElementBefore(Nod current, Nod newNod) {
        newNod.next = current;
        newNod.prev = current.prev;
        current.prev.next = newNod;
        current.prev = newNod;
        size++;
    }

    protected void delElement(Nod current) {
        if (size == 1) {
            head = null;
        } else {
            current.prev.next = current.next;
            current.next.prev = current.prev;
            if (current == head) {
                head = current.next;
            }
        }
        size--;
    }

    public LinkedVector () {
        head = null;
        size = 0;
    }

    public LinkedVector (int n) {
        head = new Nod();
        head.next = head;
        head.prev = head;
        size = n;
        for (int i = 1; i < size; i++) {
            Nod newNod = new Nod();
            goToElement(i-1).next = newNod;
            head.prev = newNod;
            newNod.prev = goToElement(i-1);
            newNod.next = head;
        }
    }

    @Override
    public void fillFromMass(double[] data) {
        LinkedVector lv =new LinkedVector(data.length);
        Nod current = lv.head;
        for (int i = 0; i < lv.size; i++) {
            current.element = data[i];
            current = current.next;
        }
        head = lv.head;
        size = lv.size;
    }

    @Override
    public void fillFromVector(Vector vector) {
        LinkedVector lv =new LinkedVector(vector.getSize());
        Nod current = lv.head;
        for (int i = 0; i < lv.size; i++) {
            current.element = vector.getElement(i);
            current = current.next;
        }
        head = lv.head;
        size = lv.size;
     }

    @Override
    public boolean equals(Object obj){
        if (this == obj) return true;
        if (!(obj instanceof Vector)) return false;
        Vector vector = (Vector) obj;
        if (vector.getSize()!=size) return false;
        for (int i=0; i< size;i++)
            if (goToElement(i).element != vector.getElement(i))
                return false;
        return true;
    }

    @Override
    public Vector sum(Vector vector) throws IncompatibleVectorSizesException {
        if (vector.getSize()!=size) throw new IncompatibleVectorSizesException("Vectors have different sizes");
        Nod current = head;
        for (int i=0; i< size;i++){
            current.element += vector.getElement(i);
            current = current.next;
        }
        return this;
    }

    @Override
    public Vector mult(double k) {
        Nod current = head;
        for (int i=0; i< size;i++){
            current.element *= k;
            current = current.next;
        }
        return this;
    }

    @Override
    public int getSize() {
        return size;
    }

    @Override
    public double getElement(int index) {
        if (index<0 || index>size-1) throw new VectorIndexOutOfBoundsException("Incorrect index: " + index);
        return goToElement(index).element;
    }

    @Override
    public void setElement(int index, double value) {
        if (index<0 || index>size-1) throw new VectorIndexOutOfBoundsException("Incorrect index: " + index);
        goToElement(index).element = value;
    }

    @Override
    public void addElement(double value) {
        size++;
        if (size==1) {
            head = new Nod (value);
            head.next = head;
            head. prev = head;
            return;
        }
        Nod newNod = new Nod(value);
        goToElement(size-2).next = newNod;
        head.prev = newNod;
        newNod.prev = goToElement(size-2);
        newNod.next = head;
    }

    @Override
    public void insertElement(int index, double value) {
        if (index<0 || index>size) throw new VectorIndexOutOfBoundsException("Incorrect index: " + index);
        Nod newNod = new Nod(value);
        insertElementBefore(goToElement(index), newNod);
        if (index == 0) head = newNod;
    }

    @Override
    public void deleteElement(int index) {
        if (index<0 || index>size-1) throw new VectorIndexOutOfBoundsException("Incorrect index: " + index);
        delElement(goToElement(index));
    }

    @Override
    public String toString () {
        StringBuilder str = new StringBuilder();
        Nod current = head;
        for (int i = 0; i < size; i++){
            str.append(current.element).append(" ");
            current=current.next;
        }
        str.deleteCharAt(str.length()-1);
        return str.toString();
    }

    @Override
    public LinkedVector clone() throws CloneNotSupportedException {
        LinkedVector lv = (LinkedVector) super.clone();
        lv.fillFromVector(this);
        return lv;
    }
}

