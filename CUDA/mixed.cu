// Matthew Holmes - holmem4
// Davis Putnam Solver

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/find.h>
#include <iostream>
#include <string>
#include <fstream>
#include <cstdlib>
#include <sstream>
#include <ctime>
#include <sys/time.h>

using namespace std;

vector<thrust::device_vector<int> > reduce(vector<thrust::device_vector<int> > s, int currentReduction)
{
    vector<thrust::device_vector<int> > newS;
    #pragma omp parallel for shared(newS)
    for(unsigned int i = 0; i < s.size(); i++)
    {
        thrust::device_vector<int>::iterator iter;
        iter = thrust::find(s[i].begin(), s[i].end(), currentReduction);
        if(iter != s[i].end())
        {
            continue;
        }
        iter = thrust::find(s[i].begin(), s[i].end(), -currentReduction);
        if(iter != s[i].end())
        {
           s[i].erase(iter);
           s[i].shrink_to_fit();
        }
        #pragma omp critical
        newS.push_back(s[i]);
    }
    return newS;
}

bool satisfiable(vector<thrust::device_vector<int> > &s, int currentReduction)
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

//    cout<<"WAITING PREALLOC"<<endl;
//    std::cin.ignore(std::numeric_limits<std::streamsize>::max(),'\n');
    vector<thrust::device_vector<int> > s1 = reduce(s, currentReduction);
    vector<thrust::device_vector<int> > s2 = reduce(s, -currentReduction);
//    cout<<"ALLOC OCCURED"<<endl;
//    std::cin.ignore(std::numeric_limits<std::streamsize>::max(),'\n');
    for(unsigned int i = 0; i < s.size(); i++)
    {
        s[i].clear();
        s[i].shrink_to_fit();
    }
    return satisfiable(s1, currentReduction + 1) || satisfiable(s2, currentReduction + 1);
}

vector<thrust::device_vector<int> > parseInput(string inputFile)
{
    ifstream openFile(inputFile.c_str());
    if(!openFile.is_open())
    {
        cerr<<"ERROR OPENING FILE \""<<inputFile<<"\""<<endl<<"PANIC"<<endl;
        exit(-1);
    }
    vector<thrust::device_vector<int> > newS;
    string buffer;
    while(getline(openFile, buffer))
    {
        if(buffer.length() == 0)
            continue;
        istringstream is(buffer);
        int i = 0;
        thrust::host_vector<int> temp;
        while( is >> i)
        {
            temp.push_back(i);
        }
        thrust::device_vector<int> temp2 = temp;
        newS.push_back(temp2);
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
    vector<thrust::device_vector<int> > initialState = parseInput(argv[1]);
    cout<<"Beginning Davis Putnam Procedure."<<endl;
//    std::cin.ignore(std::numeric_limits<std::streamsize>::max(),'\n');
    struct timeval begin, end;
    gettimeofday(&begin, NULL);
    if(satisfiable(initialState, 1))
    {
        cout<<"Argument is invalid."<<endl;
    }
    else
    {
        cout<<"Argument is valid."<<endl;
    }
    gettimeofday(&end, NULL);
    cout<<"MS ELAPSED: "<<((end.tv_sec - begin.tv_sec) * 1000) + ((end.tv_usec - begin.tv_usec) / 1000)<<endl;
    return 1;
}
