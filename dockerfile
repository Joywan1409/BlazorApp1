# --- Base Runtime Image ---
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
# Coolify defaults to mapping port 80 or uses the ASPNETCORE_HTTP_PORTS env
EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080

# --- Build Stage ---
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files first to leverage Docker layer caching
COPY ["BlazorApp1.sln", "./"]
COPY ["BlazorApp1/BlazorApp1.csproj", "BlazorApp1/"]
RUN dotnet restore "BlazorApp1/BlazorApp1.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/BlazorApp1"
RUN dotnet build "BlazorApp1.csproj" -c Release -o /app/build

# --- Publish Stage ---
FROM build AS publish
RUN dotnet publish "BlazorApp1.csproj" -c Release -o /app/publish /p:UseAppHost=false

# --- Final Runtime Stage ---
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BlazorApp1.dll"]
