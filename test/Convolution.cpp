#include <vector>
#include <iostream>
#include <fstream>
#include <sstream>
#include <stdexcept>

template<typename T>
std::vector<std::vector<T>> read_matrix_from_file(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        throw std::runtime_error("Unable to open file: " + filename);
    }

    std::vector<std::vector<T>> matrix;
    std::string line;
    while (std::getline(file, line)) {
        std::vector<T> row;
        std::istringstream iss(line);
        T value;
        while (iss >> value) {
            row.push_back(value);
        }
        if (!row.empty()) {
            matrix.push_back(row);
        }
    }

    return matrix;
}

template<typename T>
std::vector<std::vector<T>> convolve(const std::vector<std::vector<T>>& input, 
                                     const std::vector<std::vector<T>>& filter) {
    int input_height = input.size();
    int input_width = input[0].size();
    int filter_height = filter.size();
    int filter_width = filter[0].size();
    
    int output_height = input_height - filter_height + 1;
    int output_width = input_width - filter_width + 1;
    
    std::vector<std::vector<T>> output(output_height, std::vector<T>(output_width, 0));
    
    for (int i = 0; i < output_height; ++i) {
        for (int j = 0; j < output_width; ++j) {
            T sum = 0;
            for (int m = 0; m < filter_height; ++m) {
                for (int n = 0; n < filter_width; ++n) {
                    sum += input[i + m][j + n] * filter[m][n];
                }
            }
            output[i][j] = sum;
        }
    }
    
    return output;
}

template<typename T>
void print_matrix(const std::vector<std::vector<T>>& matrix) {
    for (const auto& row : matrix) {
        for (const auto& elem : row) {
            std::cout << elem << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

int main() {
    try {
        auto input = read_matrix_from_file<int>("input.txt");
        auto filter = read_matrix_from_file<int>("filter.txt");

        std::cout << "Input matrix:" << std::endl;
        print_matrix(input);
        
        std::cout << "Filter:" << std::endl;
        print_matrix(filter);
        
        auto result = convolve(input, filter);
        
        std::cout << "Convolution result:" << std::endl;
        print_matrix(result);
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}