# Introduction

This package is an implementation of Explicit Shape Regression with Characteristic Number for Facial Landmark Localization.

We supply a  picture "1.jpg" for testing. The boundingBox of the picture is X= 251, Y= 228, width= 304, height= 304.

Using dll under C# environment:

1. Create a new c# project named 'Demo';

2. Copy all files in this pakage into the 'Debug' or 'Release' directry of your project.

3. Add 'ESR_RF_LINK.dll' into reference.If necessary, you need to add the reference 'System.Drawing' and 'System.Windows.Forms', which you can find in Add Reference Dialog Box.

4. Run following codes for testing:
```C#
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ESR_RF_LINK;
using System.Drawing;
using System.Windows.Forms;
namespace Demo
{
    class Program
    {
        static void Main(string[] args)
        {
            //load model
            Entrance.ESR_LoadModel("LBF.model");
            string url = @"1.jpg"; //image url

            Bitmap bm = new Bitmap(url);
            Form form = new Form();
            form.Width = bm.Width;
            form.Height = bm.Height;
            form.Show();
            Graphics gp = form.CreateGraphics();
            gp.DrawImage(bm, new Point(0, 0));

            //Predict
            Console.WriteLine("Predicting Please wait");
            PointF[] result;

            System.Diagnostics.Stopwatch watch = new System.Diagnostics.Stopwatch();
            watch.Start();
            if (false)
            {
                //bitmap as input
                //return PointF[]
                result = Entrance.ESR_Predict(bm, 251, 228, 304, 304);
            }
            else
            {
                //url as input
                //return PointF[]
                result = Entrance.ESR_Predict(url, 251, 228, 304, 304);
            }
            watch.Stop();
            Console.WriteLine("Predicted");
            Console.WriteLine("fps:");
            Console.Write(1000.0f / watch.Elapsed.Milliseconds);

            //Drawing the detected points on image
            for (int i = 0; i < result.Length; i++)
            {
                gp.DrawEllipse(Pens.Red, result[i].X, result[i].Y, 2, 2);
            }

            Console.ReadKey();

        }
    }
}
```
5. For training, you can use following Function:

```C#
Entrance.ESR_Train(FormatOfimage, ImagePath, BoundingBoxFilePath, GroundtruthFilePath, NumberOfImages);

//e.g.
Entrance.ESR_Train("jpg", "C:/image/", "C:/image/boundingBox.txt", "C:/image/groundTruth.txt", 486);
```
Format of boundingBox file is as follows:
```
(X)     (Y)   (width) (height) [This line is just for showing title]
251	228	304	304
116	100	125	125
145	76	203	203
186	194	274	274
```

Format of groundTruth file is as follows:
```
(x1)    (x2)    (x3)    ... (x68)  (y1)  (y2)    (y3)  ... (y68)[This line is just for showing title]
278	279	281	...  28    285	 294	  309   ... 345
```
Using dll under C++ environment:
1. Create a new c++ project named 'Demo';

2. Copy all files in this pakage into the 'Debug' or 'Release' directry of your project.

3. Add `ESR_RF_LINK.dll` into reference.

The Function yan can use:
```C#
// load model
extern "C" __declspec(dllexport) void LoadModel(char* path)

// face alignment using image url
extern "C" __declspec(dllexport) double* UrlPredict(char* data, double x, double y, double width, double height)

// face alignment using image data
extern "C" __declspec(dllexport) double* Predict(double x, double y, double width, double height, char* data,double imHeight,double imWidth)

// output HelloWorld
extern "C" __declspec(dllexport) char* Hello()
```
