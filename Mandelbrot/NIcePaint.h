//! @file NIcePaint.h

#ifndef NICE_PAINT
#define NICE_PAINT

//-----------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <SFML/Graphics.hpp>
#include <immintrin.h>

//-----------------------------------------------------------------------------

const int   width      = 2560;
const int   height     = 1440;
const int   accuracy   = 256;
const int   max_radius = 100;
const float scale      = 0.002;

//-----------------------------------------------------------------------------

void draw_mandelbrot_slow (sf::RenderWindow &window, sf::Image &mandelbrot);

void draw_mandelbrot_fast (sf::RenderWindow &window, sf::Image &mandelbrot);

void select_mode (void (**draw_mandelbrot) (sf::RenderWindow &SFML_WINDOW_EXPORT_HPP, 
                                            sf::Image &mandelbrot                    ));

//-----------------------------------------------------------------------------

#endif //NICE_PAINT
