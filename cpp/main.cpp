#include "crc.h"
#include <stdio.h>
#include <stdlib.h>

#include <iomanip>  // Includes ::std::hex
#include <iostream> // Includes ::std::cout

#include <string>
#include <cstring>
using namespace std;

// Driver code
int main()
{

    // CRC 8 
    // int length_CRC_8 = 2;
    // uint8_t polynomial_8 = 0x1D;
    // uint8_t bytes1[] = {0x01, 0x02};
    // uint8_t rem1 = Compute_CRC8_Simple(bytes1, length_CRC_8, polynomial_8);  
    // uint8_t rem2 = Compute_CRC8(bytes1, length_CRC_8, polynomial_8);  
    // printf("Remainder Simple: 0x%X | Remainder Bytes: = 0x%X \n", rem1, rem2);

    // End of CRC 8

    // CRC 14 bits compared against lookup table
    // int length_CRC_14 = 14;
    // uint16_t polynomial_16 = 0x4021;
    // uint8_t bytes2[] = {0x8B, 0x8A, 0x1D, 0xA0, 0x18, 0x90, 0x71, 0x1D, 0x53, 0x61, 0xF6, 0xF8, 0x40, 0x98};
    // uint16_t rem3 = Compute_CRC14_Simple(bytes2, length_CRC_14, polynomial_16);  
    // uint16_t rem4 = Compute_CRC14(bytes2, length_CRC_14, polynomial_16);  
    // printf("Remainder Simple: 0x%X | Remainder Bytes: = 0x%X \n", rem3, rem4);
    // End of CRC 14 

    // CRC 16 bits compared against lookup table
    // int length_CRC_16 = 11;
    // uint16_t polynomial_16 = 0x1021;
    // uint8_t bytes4[] = {0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x31, 0xC3}; 
    // uint16_t rem3 = Compute_CRC16_Simple(bytes4, length_CRC_16, polynomial_16);  
    // uint16_t rem4 = Compute_CRC16(bytes4, length_CRC_16, polynomial_16);  
    // printf("Remainder Simple: 0x%X | Remainder Bytes: = 0x%X \n", rem3, rem4);
    // End of CRC 16 

    int length_CRC_32_i = 9; 
    uint8_t bytes3_i[] = {0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39}; 
    uint32_t polynomial_32_i = 0xBA137F9E; 
    uint32_t rem6_i = Compute_CRC32_Simple(bytes3_i, length_CRC_32_i, polynomial_32_i);
    uint32_t rem7_i = Compute_CRC32(bytes3_i, length_CRC_32_i, polynomial_32_i);
    printf("Remainder Simple: 0x%X | Remainder Bytes: = 0x%X \n", rem6_i, rem7_i);

    printf("---------------------------------------------\n");


    //CRC 32 Bits with Lookup Table
    int length_CRC_32 = 9; 
    uint8_t bytes3[] = {0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49}; 
    uint32_t polynomial_32 = 0xBA137F9E; 
    uint32_t rem6 = Compute_CRC32_Simple(bytes3, length_CRC_32, polynomial_32);
    uint32_t rem7 = Compute_CRC32(bytes3, length_CRC_32, polynomial_32);
    printf("Remainder Simple: 0x%X | Remainder Bytes: = 0x%X \n", rem6, rem7);
    // // End of CRC 32 

    // uint64_t polynomial_64 = 0x42F0E1EBA9EA3693;
    // CalculateCrcTable_CRC64(polynomial_64);

    return 0;
}

