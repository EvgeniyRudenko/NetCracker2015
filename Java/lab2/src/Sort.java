public class Sort{
    public static void selectionSort(MyVector myVector){
        for (int i = 0; i < myVector.getSize(); i++) {
            double min = myVector.getElement(i);
            int min_i = i;
            for (int j = i+1; j < myVector.getSize(); j++) {
                if (myVector.getElement(j) < min) {
                    min = myVector.getElement(j);
                    min_i = j;
                }
            }
            if (i != min_i) {
                double tmp = myVector.getElement(i);
                myVector.setElement(i,myVector.getElement(min_i));
                myVector.setElement(min_i,tmp);
            }
        }
    }
}
