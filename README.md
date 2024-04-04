VimWiki-Runner
==============

Attempt to something like an org babel for vimwiki.

Requirements
------------
- Plug
- Vimwiki (Plug 'vimwiki/vimwiki')
- async (Plug 'skywind3000/asyncrun.vim')

Install with Plug
-----------------
Plug 'giuliostramondo/vimwiki-runner'

Key Binding and usage
--------------------
To bind the execution of the code snippet to <Leader>we
Add in .vimrc
```
nmap <leader>we :RunProgram<CR>
```

Place point on the code snippet and use key binding to execute.

Examples
-------

```cpp
printf("Hello World");
```

```cpp
std::cout<<"Hi"<<std::endl;
```

```cpp
#include <iostream>
#include <map>


int provaf(int a){
    return a+1;
}

int 
provaf2(int a)
{
    return a+3;
}

int 
prova3
(
int a
)
{
    return 0;
}
class Rectangle_test{

    int width, height;
    
    public:
    Rectangle_test(int w,int h){
        width = w;
        height = h;
    }
    int getArea(){
        return width * height;
    }
    
};

std::map<int,int> prova;

std::map<int,int> returnItem(std::map<int,int> input){
    for(int i =0; i < 10; i++){
        if(i%2){
            std::cout << "Hello Odd\n";
        }else{
            std::cout << "Hello Even\n";
        }
    }
    return input;
}

Rectangle_test r(2,3);
std::cout<<"Area: "<<r.getArea()<<"\n";
prova[1]=10;
std::cout<<"Hello world 1\n"<<prova[1]<<"\n";
std::cout<<provaf(2)<<"\n"; 
std::cout<<provaf2(2)<<"\n"; 
std::cout<<returnItem(prova)[1];
return prova3(1);
```

```python

print("hello world")

```

```bash
echo "Hello world"
pwd
```
To Do
-----

- Handle CFLAGS and LFLAGS
- More Languages

