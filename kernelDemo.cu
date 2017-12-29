
// 下面是自己的项目测试02，自己将修改demo
// 成为自己的 两个大数组相加的cuda程序;
// 并且输出关键 girdDim  和 blockDim 的信息
// By  ZJF.Speedy.张建峰
// NOTE: 必须要求是X64的平台
// NOTE: X86平台运行，直接崩掉;
// Via My Test Solution Case03

#include <iostream>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <math.h>		//  Check error 用
#include <cmath>


// CPU  original ArrayAdd
void MyAdd(int n, float *x, float *y)
{
	for (int i = 0; i < n; i++)
	{
		y[i] = x[i] + y[i];
	}
}

// malloc memory aimed at CPU
void mallocCPU(int n, float *x, float *y)
{
	x = new float[n];
	y = new float[n];
}

// free memory aimed at CPU function&vars
void freeCPU(float *x, float *y)
{
	delete[] x;
	delete[] y;
}

// GPU  My test
__global__ void MyAddGPU(int n, float *x, float *y)
{
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;
	for (int i = index; i < n; i += stride)
	{
		y[i] = x[i] + y[i];
	}

	if (1 == index)	// 随意指定一个index 打印输出 两个参数如下
	{
		printf("blockDim.x = %d\n", blockDim.x);
		printf("gridDim.x = %d\n", gridDim.x);	// <<<gridDim.x, blockDim.x>>>
		// CUDA平台上 不支持C++的 相关库
		//std::cout << "gridDim.x = " << gridDim.x << std::endl;
	}
	

}

// malloc memory aimed at GPU 
void mallocGPU(int n, float *x, float *y)
{
	cudaMallocManaged(&x, n * sizeof(float));	// 注意看函数的定义 第一个arg 是 **devPtr
	cudaMallocManaged(&y, n * sizeof(float));
}

// free memory aimed at GPU funcs&vars
void freeGPU(float *x, float *y)
{
	cudaFree(x);
	cudaFree(y);
}


// GPU demo  default
__global__ void addKernel(int *c, const int *a, const int *b)
{
	int i = threadIdx.x;
	c[i] = a[i] + b[i];
}


int main()
{
	
	// -------------------------------------------
	// My Test code part 
	// -------------------------------------------
	const unsigned int N = 1 << 20;	// almost 1M elements, 2^20 = 1048576
	float *x, *y;

	//mallocCPU(N, x, y);
	//mallocGPU(N, x, y);
	cudaMallocManaged(&x, N * sizeof(float));
	cudaMallocManaged(&y, N * sizeof(float));

	// initialize x and y arrays on the CPU with for loop
	for (int i = 0; i < N; i++)
	{
		x[i] = 1.0f;
		y[i] = 2.0f;
	}

	// -------------------------------------------

	// Add vectors in parallel.

	// ---------------------------------------------
	// My test code part II 2 
	// ---------------------------------------------

	// run MyAdd on CPU 
	//MyAdd(N, x, y);

	// run MyAddGPU on the GPU
	int blockSize = 256;
	int numBlocks = (N + blockSize - 1) / blockSize;
	MyAddGPU <<<numBlocks, blockSize>>>(N, x, y);	// 
	//This type of loop in a CUDA kernel is often called a grid - stride loop
	
	// Wait for GPU to finish before accessing on host
	cudaDeviceSynchronize();

	// check for errors (as u know, all the values should be 3.0f)
	float maxError = 0.0f;
	for (int i = 0; i < N; i++)
	{
		maxError = fmax(maxError, fabs(y[i] - 3.0f));
	}
	std::cout << "\nChecking errors:\n\n" << "maxError = " << maxError << std::endl;
	//std::cout << "Running datails:\n" << std::endl;
	//std::cout << "GirdDim.x = " << gridDim.x << std::endl;
	//std::cout << "blockDim.x = " << blockDim.x << std::endl;
	// 注意这之后要试着显示和调用上面的两个关键变量


	// ---------------------------------------------

	std::cout << "------------------------------------------" << std::endl;
	std::cout << "Device Properties, as follows:" << std::endl;

	cudaError_t cudaStatus;
	int num = 0;
	cudaDeviceProp prop;
	
//	struct __device_builtin__ cudaDeviceProp
//	{
//    char   name[256];                  /**< ASCII string identifying device */
//	size_t totalGlobalMem;             /**< Global memory available on device in bytes */
//	size_t sharedMemPerBlock;          /**< Shared memory available per block in bytes */
//	int    regsPerBlock;               /**< 32-bit registers available per block */
//	int    warpSize;                   /**< Warp size in threads */
//	size_t memPitch;                   /**< Maximum pitch in bytes allowed by memory copies */
//	int    maxThreadsPerBlock;         /**< Maximum number of threads per block */
//	int    maxThreadsDim[3];           /**< Maximum size of each dimension of a block */
//	int    maxGridSize[3];             /**< Maximum size of each dimension of a grid */
//	int    clockRate;                  /**< Clock frequency in kilohertz */
//	size_t totalConstMem;              /**< Constant memory available on device in bytes */
//	int    major;                      /**< Major compute capability */
//	int    minor;                      /**< Minor compute capability */
//	size_t textureAlignment;           /**< Alignment requirement for textures */
//	size_t texturePitchAlignment;      /**< Pitch alignment requirement for texture references bound to pitched memory */
//	int    deviceOverlap;              /**< Device can concurrently copy memory and execute a kernel. Deprecated. Use instead asyncEngineCount. */
//	int    multiProcessorCount;        /**< Number of multiprocessors on device */
//	int    kernelExecTimeoutEnabled;   /**< Specified whether there is a run time limit on kernels */
//	int    integrated;                 /**< Device is integrated as opposed to discrete */
//	int    canMapHostMemory;           /**< Device can map host memory with cudaHostAlloc/cudaHostGetDevicePointer */
//	int    computeMode;                /**< Compute mode (See ::cudaComputeMode) */
//	int    maxTexture1D;               /**< Maximum 1D texture size */
//	int    maxTexture1DMipmap;         /**< Maximum 1D mipmapped texture size */
//	int    maxTexture1DLinear;         /**< Maximum size for 1D textures bound to linear memory */
//	int    maxTexture2D[2];            /**< Maximum 2D texture dimensions */
//	int    maxTexture2DMipmap[2];      /**< Maximum 2D mipmapped texture dimensions */
//	int    maxTexture2DLinear[3];      /**< Maximum dimensions (width, height, pitch) for 2D textures bound to pitched memory */
//	int    maxTexture2DGather[2];      /**< Maximum 2D texture dimensions if texture gather operations have to be performed */
//	int    maxTexture3D[3];            /**< Maximum 3D texture dimensions */
//	int    maxTexture3DAlt[3];         /**< Maximum alternate 3D texture dimensions */
//	int    maxTextureCubemap;          /**< Maximum Cubemap texture dimensions */
//	int    maxTexture1DLayered[2];     /**< Maximum 1D layered texture dimensions */
//	int    maxTexture2DLayered[3];     /**< Maximum 2D layered texture dimensions */
//	int    maxTextureCubemapLayered[2];/**< Maximum Cubemap layered texture dimensions */
//	int    maxSurface1D;               /**< Maximum 1D surface size */
//	int    maxSurface2D[2];            /**< Maximum 2D surface dimensions */
//	int    maxSurface3D[3];            /**< Maximum 3D surface dimensions */
//	int    maxSurface1DLayered[2];     /**< Maximum 1D layered surface dimensions */
//	int    maxSurface2DLayered[3];     /**< Maximum 2D layered surface dimensions */
//	int    maxSurfaceCubemap;          /**< Maximum Cubemap surface dimensions */
//	int    maxSurfaceCubemapLayered[2];/**< Maximum Cubemap layered surface dimensions */
//	size_t surfaceAlignment;           /**< Alignment requirements for surfaces */
//	int    concurrentKernels;          /**< Device can possibly execute multiple kernels concurrently */
//	int    ECCEnabled;                 /**< Device has ECC support enabled */
//	int    pciBusID;                   /**< PCI bus ID of the device */
//	int    pciDeviceID;                /**< PCI device ID of the device */
//	int    pciDomainID;                /**< PCI domain ID of the device */
//	int    tccDriver;                  /**< 1 if device is a Tesla device using TCC driver, 0 otherwise */
//	int    asyncEngineCount;           /**< Number of asynchronous engines */
//	int    unifiedAddressing;          /**< Device shares a unified address space with the host */
//	int    memoryClockRate;            /**< Peak memory clock frequency in kilohertz */
//	int    memoryBusWidth;             /**< Global memory bus width in bits */
//	int    l2CacheSize;                /**< Size of L2 cache in bytes */
//	int    maxThreadsPerMultiProcessor;/**< Maximum resident threads per multiprocessor */
//	int    streamPrioritiesSupported;  /**< Device supports stream priorities */
//	int    globalL1CacheSupported;     /**< Device supports caching globals in L1 */
//	int    localL1CacheSupported;      /**< Device supports caching locals in L1 */
//	size_t sharedMemPerMultiprocessor; /**< Shared memory available per multiprocessor in bytes */
//	int    regsPerMultiprocessor;      /**< 32-bit registers available per multiprocessor */
//	int    managedMemory;              /**< Device supports allocating managed memory on this system */
//	int    isMultiGpuBoard;            /**< Device is on a multi-GPU board */
//	int    multiGpuBoardGroupID;       /**< Unique identifier for a group of devices on the same multi-GPU board */
//	int    hostNativeAtomicSupported;  /**< Link between the device and the host supports native atomic operations */
//	int    singleToDoublePrecisionPerfRatio; /**< Ratio of single precision performance (in floating-point operations per second) to double precision performance */
//	int    pageableMemoryAccess;       /**< Device supports coherently accessing pageable memory without calling cudaHostRegister on it */
//	int    concurrentManagedAccess;    /**< Device can coherently access managed memory concurrently with the CPU */
//};
	


	cudaStatus = cudaGetDeviceCount(&num);
	for (int i = 0; i < num; i++)
	{
		cudaGetDeviceProperties(&prop, i);
		std::cout << "Device number: " << i << std::endl;
		std::cout << "Device name: " << prop.name << std::endl;
		std::cout << "maxThreadsPerBlock: " << prop.maxThreadsPerBlock << std::endl;
		std::cout << "multiProcessorCount : " << prop.multiProcessorCount << std::endl;
		std::cout << "blockDim(.x先后三个维度): " << prop.maxThreadsDim[0] <<" "
			<<prop.maxThreadsDim[1] <<" "<< prop.maxThreadsDim[2]<< std::endl;
		std::cout << "GridDim.x(.x先后三个维度): " << prop.maxGridSize[0] << " "
			<< prop.maxGridSize[1] << " " << prop.maxGridSize[2] << std::endl;
		std::cout << "concurrentKernels: " << prop.concurrentKernels << std::endl; // ?
		std::cout << "maxThreadsPerMultiProcessor: " << prop.maxThreadsPerMultiProcessor <<
			std::endl;	//  不用续行符
		std::cout << "totalGlobalMem: " << prop.totalGlobalMem << std::endl; //3G显存
		std::cout << "major & minor: " << prop.major << " " << prop.minor << std::endl; // ? 跟硬件版本有关
		std::cout << "WarpSize: " << prop.warpSize << std::endl;
		std::cout << "memPitch: " << prop.memPitch << std::endl;  // 数值按bytes计算
		std::cout << "tccDriver: " << prop.tccDriver << std::endl;
		std::cout << "singleToDoublePrecisionPerfRatio: " << prop.singleToDoublePrecisionPerfRatio << std::endl;
		std::cout << "sharedMemPerBlock: " << prop.sharedMemPerBlock << std::endl;
		

	}



	// cudaDeviceReset must be called before exiting in order for profiling and
	// tracing tools such as Nsight and Visual Profiler to show complete traces.
	

	// Free memory of MY test code partIII 3
	//freeCPU(x, y);
	cudaFree(x);
	cudaFree(y);

	return 0;
}