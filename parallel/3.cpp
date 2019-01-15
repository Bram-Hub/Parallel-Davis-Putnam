// Matthew Holmes - holmem4
// Davis Putnam Solver

#include <vector>
#include <iostream>
#include <string>
#include <fstream>
#include <cstdlib>
#include <sstream>
#include <ctime>
#include <omp.h>

using namespace std;

vector<vector<int> > reduce(vector<vector<int> > s, int currentReduction)
{
    vector<vector<int> > newS;
    for(unsigned int i = 0; i < s.size(); i++)
    {
        vector<int> temp;
        bool flag = false;
        for(unsigned int j = 0; j < s[i].size(); j++)
        {
            if(s[i][j] == currentReduction)
            {
                flag = true;
                break;
            }
            if(s[i][j] == -currentReduction)
                continue;
            else
                temp.push_back(s[i][j]);
        }
        if(flag)
            continue;
        else
            newS.push_back(temp);
    }
    return newS;
}

bool satisfiable(vector<vector<int> > s, int currentReduction)
{
    if(s.size() == 0)
    {
        return true;
    }
    bool test = true;
    #pragma omp parallel for
    for(unsigned int i = 0; i < s.size(); i++)
    {
        if(s[i].size() == 0)
        {
            test = false;
        }
    }
    if(!test)
        return test;

    vector<vector<int> > s1 = reduce(s, currentReduction);
    vector<vector<int> > s2 = reduce(s, -currentReduction);
    return satisfiable(s1, currentReduction + 1) || satisfiable(s2, currentReduction + 1);
}

vector<vector<int> > parseInput(string inputFile)
{
    ifstream openFile(inputFile.c_str());
    if(!openFile.is_open())
    {
        cerr<<"ERROR OPENING FILE \""<<inputFile<<"\""<<endl<<"PANIC"<<endl;
        exit(-1);
    }
    vector<vector<int> > newS;
    string buffer;
    while(getline(openFile, buffer))
    {
        if(buffer.length() == 0)
            continue;
        istringstream is(buffer);
        int i = 0;
        vector<int> temp;
        while( is >> i)
        {
            temp.push_back(i);
        }
        newS.push_back(temp);
    }
    return newS;
}

int main(int argc, char* argv[])
{
    if(argc != 2)
    {
        cout<<"Incorrect Arguments."<<endl;
        cout<<"Usage:"<<endl<<"\t"<<argv[0]<<" input_file"<<endl;
        return 1;
    }
    vector<vector<int> > initialState = parseInput(argv[1]);
    cout<<"Beginning Davis Putnam Procedure."<<endl;
    clock_t begin = clock();
    if(satisfiable(initialState, 1))
    {
        cout<<"Argument is invalid."<<endl;
    }
    else
    {
        cout<<"Argument is valid."<<endl;
    }
    clock_t end = clock();
    cout<<"MS ELAPSED: "<<(end - begin) / static_cast<double>(CLOCKS_PER_SEC)<<endl;
    return 1;
}
