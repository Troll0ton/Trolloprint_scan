#include "NIcePaint.h"

//-----------------------------------------------------------------------------

void select_mode (void (**draw_mandelbrot) (sf::RenderWindow &SFML_WINDOW_EXPORT_HPP,
                                            sf::Image &mandelbrot                    ))
{
    printf ("SELECT MODE (0 - slow, 1 - fast):\n");
    char inp_sym = 0;
    scanf ("%c", &inp_sym);

    switch(inp_sym)
    {
        case '0':
            printf ("Slow version:\n");
            *draw_mandelbrot = draw_mandelbrot_slow;
            break;
        case '1':
            printf ("Fast version:\n");
            *draw_mandelbrot = &draw_mandelbrot_fast;
            break;
        default:
            printf ("ERROR! Unknown maindelbrot pars!\n");
            break;

    }
}

//-----------------------------------------------------------------------------

void draw_mandelbrot_slow (sf::RenderWindow &window, sf::Image &mandelbrot)
{
    sf::Vertex point;

    float x_center = width  / 2;        
    float y_center = height / 2; 

    for(int y_point = 0; y_point < height; y_point++)
    {
        float y_curr = ((float) y_point - y_center) * scale;

        for(int x_point = 0; x_point < width; x_point++)
        {
            float x_curr = ((float) x_point - x_center) * scale;

            int iterations = 0;

            for(float x = x_curr, y = y_curr; iterations < accuracy; iterations++)
            {
                float x_pow    = x * x;
                float y_pow    = y * y;                
                float x_mul_y  = x * y;

                float cur_pos = x_pow + y_pow;

                if(cur_pos >= max_radius)
                {
                    break;
                }
                    
                x = x_pow - y_pow + x_curr;   
                y = x_mul_y + x_mul_y + y_curr;     
            }

            if(iterations < accuracy)
            {
                sf::Color color = sf::Color{(unsigned char) (iterations),
                                            (unsigned char) (iterations), 
                                            (unsigned char) (iterations) };

                mandelbrot.setPixel (x_point, y_point, color);
            }

            else
            {
                sf::Color color = sf::Color::Black;
                mandelbrot.setPixel (x_point, y_point, color);
            }                                                    
        }
    }  
}

//-----------------------------------------------------------------------------

void draw_mandelbrot_fast (sf::RenderWindow &window, sf::Image &mandelbrot)
{
    float x_center = width  / 2;        
    float y_center = height / 2; 

    // It will copy all values 8 times, because we use AVL instructions to calclulate 8 points per 
    //
    __m256 x_center_vector   = _mm256_set1_ps (x_center);
    __m256 local_pos_vector  = _mm256_set_ps  (7.f, 6.f, 5.f, 4.f, 3.f, 2.f, 1.f, 0.f);
    __m256 y_center_vector   = _mm256_set1_ps (y_center);
    __m256 max_radius_vector = _mm256_set1_ps (max_radius);

    for(int y_point = 0; y_point < height; y_point++)
    {
        float y_point_tmp = (y_point - y_center) * scale;
        __m256 y_curr_vector = _mm256_set1_ps (float(y_point_tmp)); 

        for(int x_point = 0; x_point < width; x_point += 8)
        {
            __m256 x_curr_vector = _mm256_add_ps (_mm256_set1_ps (float(x_point)), local_pos_vector);  
                                  
            x_curr_vector = _mm256_mul_ps (_mm256_sub_ps  (x_curr_vector, x_center_vector), 
                                           _mm256_set1_ps (scale)                          );     

            __m256i iterations = _mm256_set1_epi32 (0);        

            __m256 x_tmp = x_curr_vector;
            __m256 y_tmp = y_curr_vector;

            for(int i = 0; i <= accuracy; i++)
            {
                __m256 pow_x_2 = _mm256_mul_ps (x_tmp, x_tmp);
                __m256 pow_y_2 = _mm256_mul_ps (y_tmp, y_tmp);
                __m256 mul_x_y = _mm256_mul_ps (x_tmp, y_tmp);

                __m256 tot_length = _mm256_add_ps (pow_x_2, pow_y_2);
                __m256 comparison = _mm256_cmp_ps (max_radius_vector, tot_length, _CMP_GT_OQ); 

                if(!_mm256_movemask_ps (comparison)) 
                {    
                    break;
                }    

                iterations = _mm256_sub_epi32 (iterations, _mm256_castps_si256 (comparison));  

                x_tmp = _mm256_add_ps (_mm256_sub_ps (pow_x_2, pow_y_2), x_curr_vector); 
                y_tmp = _mm256_add_ps (_mm256_add_ps (mul_x_y, mul_x_y), y_curr_vector);       
            }

            for(int local_pos = 0; local_pos < 8; local_pos++)
            {
                if(((unsigned int*) &iterations)[local_pos] < accuracy)
                {
                    sf::Color color = sf::Color{(unsigned char) (((unsigned int*) &iterations)[local_pos]),
                                                (unsigned char) (((unsigned int*) &iterations)[local_pos]), 
                                                (unsigned char) (((unsigned int*) &iterations)[local_pos]) };

                    mandelbrot.setPixel (x_point + local_pos, y_point, color);
                }
                else
                {
                    mandelbrot.setPixel (x_point + local_pos, y_point, sf::Color::Black);
                }
            }                                                      
        }
    } 
}

//-----------------------------------------------------------------------------