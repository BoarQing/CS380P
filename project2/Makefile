NVCC = nvcc
NVCCFLAGS = -arch=sm_75 -O2

CUDA_SOURCE_FILES = sequential.cu cuda_basic.cu cuda_shmem.cu thrust.cu

EXECUTABLES = $(CUDA_SOURCE_FILES:.cu=)

all: $(EXECUTABLES)

%: %.cu
	$(NVCC) $(NVCCFLAGS) $< -o $@

clean:
	rm -f $(EXECUTABLES)