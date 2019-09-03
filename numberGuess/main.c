/**
 * Eliza Poland
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

char* createQuestion(char* s1, char* s2, char* s3);
void initRandom();
int randomIntRange(int low, int high);
int getGuess(char* question, int low, int high);

int main()
{
        char* s1 = "Guess must be between 1 and ";
        char* s2 = "100";
        char* s3 = "\nEnter your guess (q to quit): ";
        char* question = createQuestion(s1, s2, s3);

        int low = 1;
        int high = 100;
        initRandom();
        int secretNum = randomIntRange(low, high);

        int guess;

still_guessing:
        guess = getGuess(question, low, high);
        if (guess < 0) goto done_guessing;
        if (guess < secretNum) printf("Your guess was too low.\n");
        if (guess > secretNum) printf ("Your guess was too high.\n");
        if (guess == secretNum) goto correct;
        goto still_guessing;

correct:
        printf("Your guess was correct!\n");

done_guessing:
        return 0;
}

char* createQuestion(char* s1, char* s2, char* s3)
{
        int len1 = strlen(s1);
        int len2 = strlen(s2);
        int len3 = strlen(s3);
        int len = len1 + len2 + len3;

        char* question = malloc(len + 1);
        strcpy(question, s1);
        strcpy(question+len1, s2);
        strcpy(question+len1+len2,s3);

        return question;
}

void initRandom()
{
        unsigned int curTime = time(NULL);
        srand(curTime);
}

int randomIntRange(int low, int high)
{
        int rand = random();
        int range = high - low;
        rand = rand % range;
        rand = rand + low;
        return rand;
}

int getGuess(char* question, int low, int high)
{
        char buffer[256];
        char quit = 'q';
        int guess;

getting_input:
        guess = -1;
        printf(question);
        fgets(buffer, 256, stdin);

        if (buffer[0] == quit) goto valid_input;
        guess = atoi(buffer);

        if (guess > high) goto out_of_bounds;
        if (guess < low) goto out_of_bounds;
        goto valid_input;

out_of_bounds:
        printf("Input is invalid.\n");
        goto getting_input;

valid_input:
        return guess;

}




