#include<stdio.h>

int n; // длина массива A
int A[100]; // массив A
int B[100]; // массив B

// считывание массива
int read() { 
	printf("n? ");
	scanf("%d", &n);
	if (n < 0) {
		printf("Вы всё сломали!!!\n");
		return 1;
	}
	for (int i = 0; i < n; ++i) {
		printf("A[%d] ", i);
		scanf("%d", &A[i]);
	}
	return 0;
}

// печать массива, b_ind - длинна B
void print(int b_ind) {
	for (int i = 0; i < b_ind; ++i) {
		printf("%d ", B[i]);
    }
    printf("\n");
}

// вычисление первого положительного
int count_first_pos() {
	int first_pos_ind = -1;
    for (int i = 0; i < n && first_pos_ind == -1; ++i) {
		if (A[i] > 0) {
			first_pos_ind = i;
		}
    }
    return first_pos_ind;
}

// вычисление последниго отрицательного
int count_last_neg() {
    int last_neg_ind = -1;
    for (int i = n - 1; i > -1 && last_neg_ind == -1; i--) {
		if (A[i] < 0) {
			last_neg_ind = i;
		}
    }
    return last_neg_ind;
}

// создание B 
int make_B(int first_pos_ind, int last_neg_ind) {
	int b_ind = 0;
	for (int i = 0; i < n; ++i) {
		if (i != first_pos_ind && i != last_neg_ind) {
			B[b_ind] = A[i];
			b_ind++;
		}
    }
    return b_ind;
}

int main(int argc, char *argv[]) {
    if (read()) {
    	return 1;
    }
	int first_pos_ind = count_first_pos();
	int last_neg_ind = count_last_neg();
    print(make_B(first_pos_ind, last_neg_ind));
    return 0;
}
