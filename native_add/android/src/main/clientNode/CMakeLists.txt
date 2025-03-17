cmake_minimum_required(VERSION 3.4.1)  # for example

add_library( native_bm

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ./ICEGathering/STUNInterfaces/NATTraversalAdapter.cpp 
             ./ICEGathering/STUNInterfaces/NATTraversalAdapter.hpp 
             ./ICEGathering/ICECandidatesAdapter.h
             ./ICEGathering/ICEGathering.cpp
             )