#include "NIcePaint.h"

//-----------------------------------------------------------------------------

int main ()
{
    //Set Window                                                        
    sf::RenderWindow window (sf::VideoMode (width, height), "MANDELBROT"); // <- Name

    //Set clock
    sf::Clock clock;

    sf::Image mandelbrot;                                   //Set image
    mandelbrot.create(width, height, sf::Color::Black);     //
    sf::Texture texture;                                    //Set texture
    texture.loadFromImage(mandelbrot);                      //
    sf::Sprite sprite;                                      //Set sprite

    void (*draw_mandelbrot) (sf::RenderWindow &SFML_WINDOW_EXPORT_HPP, sf::Image &mandelbrot);

    select_mode (&draw_mandelbrot);

    while(window.isOpen ())                                 //Do while window is open
    {
        clock.restart();

        sf::Event event;                                    //Handle all events

        while(window.pollEvent (event))                     //Handle closing the window
        {                                                   //
            if(event.type == sf::Event::Closed)             //
            {                                               //
                window.close ();                            //
            }                                               //
        }                      

        for ( int i = 0; i < 100; i++ )
            draw_mandelbrot (window, mandelbrot);  

        texture.update (mandelbrot);                        //Draw it!
        sprite.setTexture(texture);                         //
        window.clear ();                                    //
        window.draw (sprite);                               //
        window.display ();                                  //

        sf::Time elapsed_time = clock.getElapsedTime ();     //Find FPS
        printf ("fps: %f\n", 1/elapsed_time.asSeconds ());   //                                                    
    }

    return 0;
}

//-----------------------------------------------------------------------------