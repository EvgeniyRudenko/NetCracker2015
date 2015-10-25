package vector;

public class Vectors {
    public static void selectionSort(Vector arrayVector){
        for (int i = 0; i < arrayVector.getSize(); i++) {
            double min = arrayVector.getElement(i);
            int min_i = i;
            for (int j = i+1; j < arrayVector.getSize(); j++) {
                if (arrayVector.getElement(j) < min) {
                    min = arrayVector.getElement(j);
                    min_i = j;
                }
            }
            if (i != min_i) {
                double tmp = arrayVector.getElement(i);
                arrayVector.setElement(i, arrayVector.getElement(min_i));
                arrayVector.setElement(min_i,tmp);
            }
        }
    }
}
