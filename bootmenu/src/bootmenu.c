#include <string.h>

#include <ncurses.h>
#include<chibi/eval.h>

char* menu_title = "< ABL Menu >";
char* help_string = "< Help [F1] | REPL [F9] | Select [Enter] >";

int main(int argc, char** argv) {
    bool shutdown = false;

    sexp_scheme_init();

    initscr();
    start_color();
    
    raw();
    cbreak();
    noecho();

    curs_set(0);

    keypad(stdscr, TRUE);

    int row;
    int col;

    getmaxyx(stdscr, row, col);

    while (!shutdown) {       
        clear();
    
        border(ACS_VLINE, ACS_VLINE, ACS_HLINE, ACS_HLINE, ACS_ULCORNER, ACS_URCORNER, ACS_LLCORNER, ACS_LRCORNER);

        mvprintw(0, (col - strlen(menu_title))/2 - 1, menu_title);

        mvprintw(row - 1, (col - strlen(help_string) - 2), help_string);
        
        refresh();
        
        int input = getch();

        if (strncmp(keyname(input), "^C", 2) == 0) {
            break;
        } else if (strncmp(keyname(input), "F1", 2) == 0) {
            // Print help here

            continue;
        } else if (strncmp(keyname(input), "F9", 2) == 0) {
            // Open up the REPL/config CLI

            continue;
        }
    }

    endwin();

    return 0;
}