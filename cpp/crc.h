#include <stdint.h>
#include <stdio.h>

// CRC for 6 Bits 
uint8_t Compute_CRC6_Simple(uint8_t bytes[], int elements, uint8_t generator)
{
    generator <<= 2; 
    uint8_t crc = 0; /* start with 0 so first byte can be 'xored' in */
    for(int j = 0; j < elements; j++)
    {
        crc ^= bytes[j]; /* XOR-in the next input byte */
        for (int i = 0; i < 8; i++)
        {
            if ((crc & 0x80) != 0)
            {
                crc = (uint8_t)((crc << 1) ^ (generator));
            }
            else
            {
                crc <<= 1;
            }
        }
    }
    return crc >> 2;
}

uint8_t Compute_CRC7_Simple(uint8_t bytes[], int elements, uint8_t generator)
{
    generator <<= 1; 
    uint8_t crc = 0; /* start with 0 so first byte can be 'xored' in */
    for(int j = 0; j < elements; j++)
    {
        crc ^= bytes[j]; /* XOR-in the next input byte */
        for (int i = 0; i < 8; i++)
        {
            if ((crc & 0x80) != 0)
            {
                crc = (uint8_t)((crc << 1) ^ (generator));
            }
            else
            {
                crc <<= 1;
            }
        }
    }
    return crc >> 1;
}

uint8_t* CalulateTable_CRC7(uint8_t generator)
{
    generator <<= 1;
    static uint8_t crctable[256];

    /* iterate over all byte values 0 - 255 */
    for (int divident = 0; divident < 256; divident++)
    {
        uint8_t currByte = (uint8_t) divident;
        
        /* calculate the CRC-8 value for current byte */
        for (uint8_t bit = 0; bit < 8; bit++)
        {
            if ((currByte & 0x80) != 0)
            {
                currByte <<= 1;
                currByte ^= generator;
            }
            else
            {
                currByte <<= 1;
            }
        }
        /* store CRC value in lookup table */
        crctable[divident] = currByte;
    }

    return crctable;
}

uint8_t Compute_CRC7(uint8_t bytes[], int elements, uint8_t generator)
{
    uint8_t* crctable = CalulateTable_CRC7(generator);

    uint8_t crc = 0;
    for(int i = 0; i < elements; i++)
    {
        /* XOR-in next input byte */
        uint8_t data = (uint8_t)(bytes[i] ^ crc);

        /* get current CRC value = remainder */
        crc = (uint8_t)(crctable[data]);
    }
    
    return crc >> 1;
}




// CRC for 8 Bits 
uint8_t Compute_CRC8_Simple(uint8_t bytes[], int elements, uint8_t generator)
{
    uint8_t crc = 0; /* start with 0 so first byte can be 'xored' in */
    for(int j = 0; j < elements; j++)
    {
        crc ^= bytes[j]; /* XOR-in the next input byte */
        for (int i = 0; i < 8; i++)
        {
            if ((crc & 0x80) != 0)
            {
                crc = (uint8_t)((crc << 1) ^ generator);
            }
            else
            {
                crc <<= 1;
            }
        }
    }
    return crc;
}

uint8_t* CalulateTable_CRC8(uint8_t generator)
{

    static uint8_t crctable[256];

    /* iterate over all byte values 0 - 255 */
    for (int divident = 0; divident < 256; divident++)
    {
        uint8_t currByte = (uint8_t) divident;
        
        /* calculate the CRC-8 value for current byte */
        for (uint8_t bit = 0; bit < 8; bit++)
        {
            if ((currByte & 0x80) != 0)
            {
                currByte <<= 1;
                currByte ^= generator;
            }
            else
            {
                currByte <<= 1;
            }
        }
        /* store CRC value in lookup table */
        crctable[divident] = currByte;
    }

    return crctable;
}

uint8_t Compute_CRC8(uint8_t bytes[], int elements, uint8_t generator)
{
    uint8_t* crctable = CalulateTable_CRC8(generator);

    uint8_t crc = 0;
    for(int i = 0; i < elements; i++)
    {
        /* XOR-in next input byte */
        uint8_t data = (uint8_t)(bytes[i] ^ crc);
        /* get current CRC value = remainder */
        crc = (uint8_t)(crctable[data]);
    }
    
    return crc;
}


// CRC for 14 Bits

uint16_t Compute_CRC14_Simple(uint8_t bytes[], int elements, uint16_t generator)
{

    generator <<= 2; 
    uint16_t crc = 0; /* CRC value is 16bit */

    for(int j = 0; j < elements; j++)
    {
        crc ^= (uint16_t(bytes[j] << 8)); /* move byte into MSB of 16bit CRC */

        for (int i = 0; i < 8; i++)
        {
            if ((crc & 0x8000) != 0) /* test for MSB = bit 15 */
            {
                crc = (uint16_t((crc << 1) ^ generator));
            }
            else
            {
                crc <<= 1;
            }
        }
    }

    return crc >> 2;
}


uint16_t* CalculateTable_CRC14(uint16_t generator)
{
    generator <<= 2; 
    static uint16_t crctable16[256];

    for (int divident = 0; divident < 256; divident++) /* iterate over all possible input byte values 0 - 255 */
    {
        uint16_t curByte = (uint16_t(divident << 8)); /* move divident byte into MSB of 16Bit CRC */ 
        
        for (uint8_t bit = 0; bit < 8; bit++) /* bit at a time */
        {
            if ((curByte & 0x8000) != 0)
            {
                curByte <<= 1;
                curByte ^= generator;
                //curByte = (curByte << 1) ^ generator;
            }
            else
            {
                curByte <<= 1;
            }
        }

        crctable16[divident] = curByte;
    }

    
    // printf("{");
    // for(int i = 0; i < 256; i++) { 
    //     if(i != 255)
    //         printf("0x%X, ", crctable16[i]);
    //     else
    //         printf("0x%X", crctable16[i]);
    // }
    // printf("}\n\n");

    return crctable16;
}


uint16_t Compute_CRC14(uint8_t bytes[], int elements, uint16_t generator)
{
    uint16_t* crcTable = CalculateTable_CRC14(generator);

    uint16_t crc = 0;
    for(int i = 0; i < elements; i++)
    {
        /* XOR-in next input byte into MSB of crc, that's our new intermediate divident */
        uint8_t pos = (uint8_t) ((crc >> 8) ^ bytes[i]); /* equal: ((crc ^ (b << 8)) >> 8) */
        /* Shift out the MSB used for division per lookuptable and XOR with the remainder */
       crc = (uint16_t)((crc << 8) ^ (uint16_t)(crcTable[pos]));
    }

    return crc >> 2;
}


// CRC for 15 Bits

uint16_t Compute_CRC15_Simple(uint8_t bytes[], int elements, uint16_t generator)
{

    generator <<= 1; 
    uint16_t crc = 0; /* CRC value is 16bit */

    for(int j = 0; j < elements; j++)
    {
        crc ^= (uint16_t(bytes[j] << 8)); /* move byte into MSB of 16bit CRC */

        for (int i = 0; i < 8; i++)
        {
            if ((crc & 0x8000) != 0) /* test for MSB = bit 15 */
            {
                crc = (uint16_t((crc << 1) ^ generator));
            }
            else
            {
                crc <<= 1;
            }
        }
    }

    return crc >> 1;
}



// CRC for 16 Bits 

uint16_t Compute_CRC16_Simple(uint8_t bytes[], int elements, uint16_t generator)
{
    uint16_t crc = 0; /* CRC value is 16bit */

    for(int j = 0; j < elements; j++)
    {
        crc ^= (uint16_t(bytes[j] << 8)); /* move byte into MSB of 16bit CRC */

        for (int i = 0; i < 8; i++)
        {
            if ((crc & 0x8000) != 0) /* test for MSB = bit 15 */
            {
                crc = (uint16_t((crc << 1) ^ generator));
            }
            else
            {
                crc <<= 1;
            }
        }
    }

    return crc;
}


uint16_t* CalculateTable_CRC16(uint16_t generator)
{
    static uint16_t crctable16[256];

    for (int divident = 0; divident < 256; divident++) /* iterate over all possible input byte values 0 - 255 */
    {
        uint16_t curByte = (uint16_t(divident << 8)); /* move divident byte into MSB of 16Bit CRC */ 
        for (uint8_t bit = 0; bit < 8; bit++)
        {
            if ((curByte & 0x8000) != 0)
            {
                curByte <<= 1;
                curByte ^= generator;
            }
            else
            {
                curByte <<= 1;
            }
        }
        crctable16[divident] = curByte;
    }

    return crctable16;
}


uint16_t Compute_CRC16(uint8_t bytes[], int elements, uint16_t generator)
{
    uint16_t* crctable16 = CalculateTable_CRC16(generator);

    uint16_t crc = 0;
    for(int i = 0; i < elements; i++)
    {
        /* XOR-in next input byte into MSB of crc, that's our new intermediate divident */
        uint8_t pos = (uint8_t) ((crc >> 8) ^ bytes[i]); /* equal: ((crc ^ (b << 8)) >> 8) */
        /* Shift out the MSB used for division per lookuptable and XOR with the remainder */



        printf("CRC TABLE: %d, 0x%X \n", pos, crctable16[pos]);

        crc = (uint16_t)((crc << 8) ^ (uint16_t)(crctable16[pos]));
    }

    return crc;
}


// CRC 32 bits 

uint32_t Compute_CRC32_Simple(uint8_t bytes[], int elements, uint32_t generator)
{
    uint32_t crc = 0; /* CRC value is 32bit */

    for(int j = 0; j < elements; j++)
    {
        crc ^= (uint32_t)(bytes[j] << 24); /* move byte into MSB of 32bit CRC */

        for (int i = 0; i < 8; i++)
        {
            if ((crc & 0x80000000) != 0) /* test for MSB = bit 31 */
            {
                crc = (uint32_t)((crc << 1) ^ generator);
            }
            else
            {
                crc <<= 1;
            }
        }
    }
    return crc;
}

uint32_t* CalculateCrcTable_CRC32(uint32_t generator)
{
    static uint32_t crcTable[256];

    for (int divident = 0; divident < 256; divident++) /* iterate over all possible input byte values 0 - 255 */
    {
        uint32_t curByte = (uint32_t)(divident << 24); /* move divident byte into MSB of 32Bit CRC */
        for (uint8_t bit = 0; bit < 8; bit++)
        {
            if ((curByte & 0x80000000) != 0)
            {
                curByte <<= 1;
                curByte ^= generator;
            }
            else
            {
                curByte <<= 1;
            }
        }
        crcTable[divident] = curByte;
    }

    // printf("{");
    // for(int i = 0; i < 256; i++) { 
    //     if(i != 255)
    //         printf("0x%X, ", crcTable[i]);
    //     else
    //         printf("0x%X", crcTable[i]);
    // }
    // printf("}\n\n");

    return crcTable;
}

uint32_t Compute_CRC32(uint8_t bytes[], int elements, uint32_t generator)
{
    uint32_t* crcTable = CalculateCrcTable_CRC32(generator);

    uint32_t crc = 0;
    for(int i = 0; i < elements; i++)
    {
        /* XOR-in next input byte into MSB of crc and get this MSB, that's our new intermediate divident */
        //uint8_t pos = (uint8_t)((crc ^ (bytes[i] << 24)) >> 24); /*((crc ^ (b << 8)) >> 8) */
        
        uint8_t pos = (uint8_t) ((crc >> 24) ^ bytes[i]); /* equal: ((crc ^ (b << 8)) >> 8) */
        
        printf("CRC TABLE POS: pos = 0x%X, CRC REG: 0x%X, BYTE REG: 0x%X \n", pos, crc, bytes[i]);

        /* Shift out the MSB used for division per lookuptable and XOR with the remainder */
        
        
        //printf("CRC TABLE POS: pos = %d,  0x%X \n", pos, crcTable[pos]);

        crc = (uint32_t)((crc << 8) ^ (uint32_t)(crcTable[pos]));
    }

    return crc;
}

uint64_t* CalculateCrcTable_CRC64(uint64_t generator)
{
    static uint64_t crcTable [256];

    for (int divident = 0; divident < 256; divident++)
    {
        uint64_t curByte = (uint64_t)((uint64_t)divident << 56);
        for (uint8_t bit = 0; bit < 8; bit++)
        {
            if ((curByte & 0x8000000000000000) != 0)
            {
                curByte <<= 1;
                curByte ^= generator;
            }
            else
            {
                curByte <<= 1;
            }
        }

        crcTable[divident] = curByte;
    }

    printf("{");
    for(int i = 0; i < 256; i++) 
    { 
        if(i != 255)
            printf("0x%llx, ", crcTable[i]);
        else
            printf("0x%llx", crcTable[i]);
    }
    printf("}\n\n");
   
}
